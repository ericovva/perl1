Домашнее задание Habr
=====================

Требуется написать программу, которая выдает различные данные по habrahabr.ru. Причем некоторые данные сохраняются в базу, чтобы не повторять запрос, а некоторые — в memcached, чтобы отвечать еще быстрей.

Сначала данные ищутся в memcached; если их нет — в базе; если их нет — скачиваются с сайта. Если какой-то из этих этапов для этого запроса не поддерживается, в таблице ниже будет отсуствовать метка `R` (read).

Если данные скачались с сайта, они записываются в базу и memcached. Если данные удалось получить из базы, они записываются в memcached. Если какой-то из этих этапов для этого запроса не поддерживается, в таблице ниже будет отсуствовать метка `W` (write).

Общие требования
----------------

* ООП-код.
* `Getopt::Long`.
* `DBI` или `DBIx::Class` на выбор. В любом случае в проекте должнен быть способ воспроизвести схему (пусть даже просто SQL-файл).
* Честный HTML-парсер (не регулярки).
* Любая реляционная СУБД, включая SQLite.
* Нужен конфиг отдельный файлом. Он должен хранить по крайней мере данные о том, как соединиться с базой и с memcached.
* memcached — опциональная часть; задание без него будет принято с небольшим штрафом.


Общие ключи
-----------

| Ключ |  Аргумент | Описание |
|------|-----------|----------|
| `--format` | `json|jsonl|xml|csv|ddp` | Определяет формат вывода данных (достаточно поддержать `json` и еще любой один) |
| `--refresh` | — | Использовать наиболее истинный возможный источник данных (самый правый в таблице с меткой `R`) |

Что скачивать
-------------

Поля пользователя: ник, карма, рейтинг.

Поля поста: автор, тема, общий рейтинг, количество просмотров, количество звезд.

Возможные запросы
-----------------

| Команда | Описание | memcached | База | Сайт |
|---------|----------|-----------|------|------|
| `user --name XXX` | Информацию по пользователю с именем XXX | RW | RW | R |
| `user --post XXX` | Информация по пользователю, который является автором поста XXX | W (только по имени пользователя, привязку к посту не хранить) | RW | R |
| `commenters --post XXX` | Информацию по пользователям, которые комментировали пост XXX | — | RW (также сохранять данные по посту) | R |
| `post --id XXX` | Информация по посту с id=XXX | — | RW (также сохранять данные по комментаторам) | R |
| `self_commentors` | Информация по всем известным пользователям, которые хоть раз комментировали свои посты | — | R | — |
| `desert_posts --n XXX` | Информация по всем известным постам, где меньше XXX комментариев | — | R | — |

Пример
------

```bash
$ bin/habr.pl commenters --post 274771 --format jsonl
{"username": "pushtaev", "karma": 19, "rating": 0}
{"username": "nickolas_v", "karma": 0, "rating": 0}
...
```

Дополнительные задания
----------------------

* У Хабра есть несколько дружественных сайтов с идентичной версткой, таких как GeekTimes. Можно разрешить пользователю выбирать сайт с помощью параметра `--site`.
* Чтобы быстрей заполнить базу, можно разрешить команде `post` принимать множество `id`, а еще лучше страницы ленты для обкачки, такие как «[Интересные публикации](https://habrahabr.ru/interesting/)».
* Если хранить дату последнего обновления информации для каждого поста и пользователя, можно сделать команду, обновляющую информацию по всем объектам старше `N` секунд.
* Для `self_commentors` и `desert_posts` тоже можно предусмотреть кеширование в memcached, но при этом сбрасывать этот кеш каждый раз, когда данные реально могли поменяться (обкачан новый пост и т. д.).
