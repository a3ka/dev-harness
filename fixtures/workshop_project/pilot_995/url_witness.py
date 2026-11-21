"""Independent URL oracle for the 995 runtime probe and its regression."""
from urllib.parse import urlsplit

WITNESS_SYNTHETIC_URL = 'https://api.example.invalid'


def synthetic_origin(url):
    """995:41: HTTPS origin in .invalid, with no credentials or other parts."""
    part = urlsplit(url)
    return (part.scheme == 'https' and part.username is None and part.password is None
            and part.port is None and not part.path and not part.query and not part.fragment
            and (part.hostname or '').endswith('.invalid'))


def matches_witness(url):
    if not synthetic_origin(WITNESS_SYNTHETIC_URL):
        raise RuntimeError('WITNESS_NOT_SYNTHETIC: свидетель вне класса .invalid (995:41)')
    return url == WITNESS_SYNTHETIC_URL
