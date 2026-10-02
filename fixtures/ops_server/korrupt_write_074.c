/*
 * korrupt_write_074 — структурный корруптор записи батареи 074 (клетка к1b).
 *
 * ПРЕДМЕТ (B3, адверсарий r2: tee-копирование без перечитывания проходило
 * батарею): шины cp/cat/install в PATH инертны для механизмов вне их
 * множества. Структурное закрытие — LD_PRELOAD-перехват САМОЙ записи:
 * первый write-класс-вызов (write/pwrite64/writev/fwrite/fwrite_unlocked/
 * copy_file_range/sendfile) в дескриптор, ОТКРЫТЫЙ НА ЗАПИСЬ и ведущий по
 * пути с базовым именем orch-loop (суффикс «/orch-loop»), несёт один
 * испорченный байт (buf[0] ^= 0xFF) в КОПИИ буфера; буфер вызывающего
 * не трогаем. Тогда ЛЮБОЙ механизм копирования (cp/cat/install/tee/dd/
 * python/shell-редирект с cat, rsync) получает испорченную запись; честный
 * субъект обязан перечитыванием sha256 отказаться rc 1 «расхождение»,
 * ленивый — пропустить и быть пойманным клеткой.
 *
 * ПРИНЦИП НАДЕЖНОСТИ: цель определяется НЕ перехватом open (таблица
 * дескрипторов умирает на exec: «cat > dst» открывает адресат ДО exec, а
 * glibc-internal openat мимо PLT вовсе невидим), а ленивым спросом у ядра
 * на каждом write-класс-вызове: readlink(/proc/self/fd/N) даёт путь,
 * fcntl(F_GETFL) — режим доступа. Кто бы ни открыл дескриптор — родная
 * оболочка субъекта, dup2 внутри dd, внутренний openat у fopen — порча
 * доходит. Чтения (O_RDONLY) не трогаем: перечитывание честного субъекта
 * видит испорченные байты, источник остаётся цел.
 *
 * Неинертность канала самодоказуема: каждый испорченный вызов дописывает
 * строку в журнал $ORCH074_CORRUPT_LOG — клетка печатает счётчик записей.
 *
 * ГРАНИЦА НАБЛЮДАЕМОСТИ (ненаблюдаемое — красное, не зелёное; арбитраж
 * 074-k1b П3): rename-класс (mv внутри одной ФС не пишет байты вообще),
 * прямые сисколлы мимо PLT (syscall(2) у статически слинкованного
 * субъекта) и pwritev/pwritev2/splice/mmap — клетка к1b судит такую
 * запись fail-closed: «перечитывание НЕ ДОКАЗАНО».
 *
 * Сборка: cc -shared -fPIC -O2 -Wall -o korrupt_write_074.so korrupt_write_074.c
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <sys/syscall.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#define TARGET "orch-loop"
#define PATHSZ 4096

static pthread_mutex_t g_lk = PTHREAD_MUTEX_INITIALIZER;
static pthread_once_t g_once = PTHREAD_ONCE_INIT;

/* испорченные (fd, путь) — по одному искажению на пару */
struct done { int fd; char path[PATHSZ]; };
static struct done *g_done = NULL;
static size_t g_dn = 0, g_dc = 0;

static ssize_t (*r_write)(int, const void *, size_t);
static ssize_t (*r_pwrite)(int, const void *, size_t, off_t);
static ssize_t (*r_pread)(int, void *, size_t, off_t);
static ssize_t (*r_writev)(int, const struct iovec *, int);
static ssize_t (*r_cfr)(int, void *, int, void *, size_t, unsigned int);
static ssize_t (*r_sendfile)(int, int, off_t *, size_t);
static size_t (*r_fwrite)(const void *, size_t, size_t, FILE *);
static int (*r_open)(const char *, int, ...);
static int (*r_close)(int);
static off_t (*r_lseek)(int, off_t, int);
static int (*r_fcntl)(int, int, ...);

static void g_resolve(void) {
    r_write    = dlsym(RTLD_NEXT, "write");
    r_pwrite   = dlsym(RTLD_NEXT, "pwrite");
    r_pread    = dlsym(RTLD_NEXT, "pread");
    r_writev   = dlsym(RTLD_NEXT, "writev");
    r_cfr      = dlsym(RTLD_NEXT, "copy_file_range");
    r_sendfile = dlsym(RTLD_NEXT, "sendfile");
    r_fwrite   = dlsym(RTLD_NEXT, "fwrite");
    r_open     = dlsym(RTLD_NEXT, "open");
    r_close    = dlsym(RTLD_NEXT, "close");
    r_lseek    = dlsym(RTLD_NEXT, "lseek");
    r_fcntl    = dlsym(RTLD_NEXT, "fcntl");
}

/* путь дескриптора по словам ядра; NULL — не цель (чтение/не orch-loop) */
static int fd_target(int fd, char *out, size_t out_sz) {
    char proc[64], link[PATHSZ];
    ssize_t n;
    int fl, acc;
    size_t L;
    snprintf(proc, sizeof proc, "/proc/self/fd/%d", fd);
    n = readlink(proc, link, sizeof link - 1);
    if (n <= 0) return 0;
    link[n] = '\0';
    L = strlen(TARGET);
    if (!(strcmp(link, TARGET) == 0 ||
          (n > (ssize_t)L + 1 && strcmp(link + n - L - 1, "/" TARGET) == 0)))
        return 0;
    fl = r_fcntl(fd, F_GETFL);
    if (fl < 0) return 0;
    acc = fl & O_ACCMODE;
    if (acc != O_WRONLY && acc != O_RDWR) return 0; /* чтения не трогаем */
    snprintf(out, out_sz, "%s", link);
    return 1;
}

/* атомарно: fd — цель и ещё не испорчен в этом процессе; метит done */
static int claim(int fd, char *out_path, size_t out_sz) {
    size_t i;
    int hit = 0;
    char p[PATHSZ];
    pthread_mutex_lock(&g_lk);
    if (fd_target(fd, p, sizeof p)) {
        hit = 1;
        for (i = 0; i < g_dn; i++) {
            if (g_done[i].fd == fd && strcmp(g_done[i].path, p) == 0) {
                hit = 0; /* уже испорчен */
                break;
            }
        }
        if (hit) {
            if (g_dn == g_dc) {
                size_t cap = g_dc ? g_dc * 2 : 8;
                struct done *t = realloc(g_done, cap * sizeof *t);
                if (!t) { pthread_mutex_unlock(&g_lk); return 0; }
                g_done = t; g_dc = cap;
            }
            g_done[g_dn].fd = fd;
            snprintf(g_done[g_dn].path, sizeof g_done[0].path, "%s", p);
            g_dn++;
            snprintf(out_path, out_sz, "%s", p);
        }
    }
    pthread_mutex_unlock(&g_lk);
    return hit;
}

/* журнал неинертности: одна строка = один испорченный вызов */
static void log_corrupt(const char *what, const char *path) {
    const char *lg;
    char line[PATHSZ + 64];
    int fd;
    ssize_t n;
    if (!r_open || !r_write || !r_close) return;
    lg = getenv("ORCH074_CORRUPT_LOG");
    if (!lg || !lg[0]) return;
    fd = r_open(lg, O_WRONLY | O_CREAT | O_APPEND, 0644);
    if (fd < 0) return;
    n = snprintf(line, sizeof line, "corrupt %s %s\n", what, path);
    if (n > 0) r_write(fd, line, (size_t)n);
    r_close(fd);
}

/* ── испорченная запись: первый байт первой записи ^= 0xFF, копией буфера ──── */

ssize_t write(int fd, const void *buf, size_t n) {
    char path[PATHSZ];
    char *copy;
    ssize_t r;
    pthread_once(&g_once, g_resolve);
    if (buf && n && claim(fd, path, sizeof path)) {
        copy = malloc(n);
        if (copy) {
            memcpy(copy, buf, n);
            copy[0] = (char)(unsigned char)copy[0] ^ 0xFF;
            r = r_write(fd, copy, n);
            free(copy);
            if (r >= 0) log_corrupt("write", path);
            return r;
        }
    }
    return r_write(fd, buf, n);
}

ssize_t pwrite(int fd, const void *buf, size_t n, off_t off) {
    char path[PATHSZ];
    char *copy;
    ssize_t r;
    pthread_once(&g_once, g_resolve);
    if (buf && n && claim(fd, path, sizeof path)) {
        copy = malloc(n);
        if (copy) {
            memcpy(copy, buf, n);
            copy[0] = (char)(unsigned char)copy[0] ^ 0xFF;
            r = r_pwrite(fd, copy, n, off);
            free(copy);
            if (r >= 0) log_corrupt("pwrite", path);
            return r;
        }
    }
    return r_pwrite(fd, buf, n, off);
}

ssize_t pwrite64(int fd, const void *buf, size_t n, off_t off) {
    return pwrite(fd, buf, n, off);
}

ssize_t writev(int fd, const struct iovec *iov, int cnt) {
    char path[PATHSZ];
    struct iovec *cp;
    char *b0 = NULL;
    int i;
    ssize_t r;
    pthread_once(&g_once, g_resolve);
    if (iov && cnt > 0 && claim(fd, path, sizeof path)) {
        cp = malloc((size_t)cnt * sizeof *cp);
        if (cp) {
            memcpy(cp, iov, (size_t)cnt * sizeof *cp);
            for (i = 0; i < cnt; i++) {
                if (cp[i].iov_len) {
                    b0 = malloc(cp[i].iov_len);
                    if (b0) {
                        memcpy(b0, cp[i].iov_base, cp[i].iov_len);
                        b0[0] = (char)(unsigned char)b0[0] ^ 0xFF;
                        cp[i].iov_base = b0;
                    }
                    break;
                }
            }
            if (b0) {
                r = r_writev(fd, cp, cnt);
                free(b0); free(cp);
                if (r >= 0) log_corrupt("writev", path);
                return r;
            }
            free(cp);
        }
    }
    return r_writev(fd, iov, cnt);
}

static size_t fw_common(const char *what, const void *buf, size_t sz, size_t n, FILE *f,
                        size_t (*real_fw)(const void *, size_t, size_t, FILE *)) {
    char path[PATHSZ];
    char *copy;
    size_t tot = sz * n, r;
    pthread_once(&g_once, g_resolve);
    int fd = fileno(f);
    if (buf && tot && f && fd >= 0 && claim(fd, path, sizeof path)) {
        copy = malloc(tot);
        if (copy) {
            memcpy(copy, buf, tot);
            copy[0] = (char)(unsigned char)copy[0] ^ 0xFF;
            r = real_fw(copy, sz, n, f);
            free(copy);
            if (r == n) log_corrupt(what, path);
            return r;
        }
    }
    return real_fw(buf, sz, n, f);
}

size_t fwrite(const void *buf, size_t sz, size_t n, FILE *f) {
    pthread_once(&g_once, g_resolve);
    return fw_common("fwrite", buf, sz, n, f, r_fwrite);
}
#undef fwrite_unlocked
size_t fwrite_unlocked(const void *buf, size_t sz, size_t n, FILE *f) {
    static size_t (*real_fwu)(const void *, size_t, size_t, FILE *);
    pthread_once(&g_once, g_resolve);
    if (!real_fwu) real_fwu = dlsym(RTLD_NEXT, "fwrite_unlocked");
    return fw_common("fwrite_unlocked", buf, sz, n, f, real_fwu);
}

/* ── ядерное копирование (ускорения cp/python): pread→порча→pwrite по тем же
 * смещениям; при отказе эмуляции -2 — вызывающий зовёт настоящий вызов ─────── */

static ssize_t kern_copy(int in_fd, void *off_in, int out_fd, void *off_out,
                         size_t len, const char *what) {
    char path[PATHSZ];
    char *b;
    off_t in_off, out_off;
    size_t chunk = len > (1u << 20) ? (1u << 20) : len;
    ssize_t n;
    pthread_once(&g_once, g_resolve);
    if (!len || !claim(out_fd, path, sizeof path)) return -2;
    b = malloc(chunk);
    if (!b) return -2;
    in_off  = off_in  ? *(off_t *)off_in  : r_lseek(in_fd, 0, SEEK_CUR);
    out_off = off_out ? *(off_t *)off_out : r_lseek(out_fd, 0, SEEK_CUR);
    n = r_pread(in_fd, b, chunk, in_off);
    if (n <= 0) { free(b); return -2; }
    b[0] = (char)(unsigned char)b[0] ^ 0xFF;
    n = r_pwrite(out_fd, b, (size_t)n, out_off);
    free(b);
    if (n < 0) return -2;
    if (!off_in)  r_lseek(in_fd, n, SEEK_CUR);
    if (!off_out) r_lseek(out_fd, n, SEEK_CUR);
    if (off_in)  *(off_t *)off_in  += n;
    log_corrupt(what, path);
    return n;
}

ssize_t copy_file_range(int in_fd, off64_t *off_in, int out_fd, off64_t *off_out,
                        size_t len, unsigned int flags) {
    ssize_t r;
    pthread_once(&g_once, g_resolve);
    r = kern_copy(in_fd, off_in, out_fd, off_out, len, "copy_file_range");
    if (r != -2) return r;
    return r_cfr(in_fd, off_in, out_fd, off_out, len, flags);
}

ssize_t sendfile(int out_fd, int in_fd, off_t *off, size_t count) {
    ssize_t r;
    pthread_once(&g_once, g_resolve);
    r = kern_copy(in_fd, off, out_fd, NULL, count, "sendfile");
    if (r != -2) return r;
    return r_sendfile(out_fd, in_fd, off, count);
}

ssize_t sendfile64(int out_fd, int in_fd, off64_t *off, size_t count) {
    return sendfile(out_fd, in_fd, (off_t *)off, count);
}

/* прямые сисколлы мимо PLT-имён (CPython os.sendfile/copy_file_range): тот же
 * kern_copy по номерам SYS_*; прочие номера идут настоящему syscall(2) как есть */
long syscall(long number, ...) {
    static long (*r_syscall)(long, ...);
    long a, b, c, d, e, f;
    ssize_t r;
    va_list ap;
    va_start(ap, number);
    a = va_arg(ap, long); b = va_arg(ap, long); c = va_arg(ap, long);
    d = va_arg(ap, long); e = va_arg(ap, long); f = va_arg(ap, long);
    va_end(ap);
    if (!r_syscall) r_syscall = dlsym(RTLD_NEXT, "syscall");
    if (number == SYS_copy_file_range) {
        r = kern_copy((int)a, (void *)b, (int)c, (void *)d, (size_t)e,
                      "syscall.copy_file_range");
        if (r != -2) return r;
        return r_syscall(number, a, b, c, d, e, f);
    }
    if (number == SYS_sendfile) {
        r = kern_copy((int)b, (void *)c, (int)a, NULL, (size_t)d,
                      "syscall.sendfile");
        if (r != -2) return r;
        return r_syscall(number, a, b, c, d, e, f);
    }
    return r_syscall(number, a, b, c, d, e, f);
}
