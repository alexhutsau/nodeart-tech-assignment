create table authors (
  id serial primary key,
  email text not null unique,
  role text not null default 'author' check (role in ('author', 'admin'))
);

create table tags (
  value text primary key
);

create table collections (
  id serial primary key,
  name text not null
);

create table author_collection (
  author_id integer not null references authors(id),
  collection_id integer not null references collections(id),
  
  primary key (author_id, collection_id)
);

create table images (
  id serial primary key,
  url text not null,
  author_id integer not null references authors(id),
  collection_id integer not null references collections(id),
  created_at timestamptz not null default now(),
  status text not null default 'published'
);

create table image_tag (
  image_id integer not null references images(id),
  tag_value text not null references tags(value),

  primary key (image_id, tag_value)
);

insert into authors (email, role) values
('author1@example.com', 'admin'),
('author2@example.com', 'author'),
('author3@example.com', 'author'),
('author4@example.com', 'author');

insert into collections (name) values
('collection1'),
('collection2');

insert into author_collection values
('2', '1'),
('3', '2'),
('4', '2');

insert into tags values
('tag1'),
('tag2'),
('tag3'),
('tag4'),
('tag5');

insert into images (url, author_id, collection_id) values
('url1', '2', '1'),
('url2', '2', '1'),
('url3', '2', '1'),
('url4', '3', '2'),
('url5', '3', '2'),
('url6', '3', '2'),
('url7', '4', '2'),
('url8', '4', '2'),
('url9', '4', '2');

insert into image_tag values
('1', 'tag1'),
('1', 'tag2'),
('3', 'tag3'),
('3', 'tag4'),
('4', 'tag5'),
('7', 'tag1'),
('7', 'tag5'),
('8', 'tag2'),
('9', 'tag1'),
('9', 'tag3');

create or replace function image_author_sort(image_row images, hasura_session json)
returns smallint as $$
with author_collection_ids as (
  select collection_id
    from author_collections
   where author_id = (hasura_session ->> 'x-hasura-user-id')::int
)
select case
  when image_row.author_id = (hasura_session ->> 'x-hasura-user-id')::int
    then 1

  when image_row.collection_id in (select collection_id from author_collection_ids)
    then 2

  else 3
end;
$$ language sql stable;
