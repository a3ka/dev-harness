"""Стаб s43 (prokhod-pressable-v-kommentarii): исполняемый текст флоу не
отделяется от формы — шапка до «---» и YAML-комментарии считаются
текстом флоу, ссылки на pressable в комментарии/шапке засчитываются
(С-2 РЕШЕНИЯ АРБИТРА contracts-132-v2-arbitraz, обход б-2 + вопрос 3);
PROKHOD_BEZ_PRESSABLE не выдаётся; на входе своей записи green там, где
эталон красен; на честных флоу (ссылки в исполняемых шагах) совпадает с
эталоном."""
from _model import m

m.ispolnimye_stroki_flo = lambda stroki: stroki
run()
