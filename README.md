# nodeart-tech-assignment

## Setup

```bash
# Setup containers (Edit docker-compose file if you need custom configuration)
$ docker-compose build

# Install dependencies
$ npm install
```

## Running the app

```bash
# Start containers
$ docker-compose up -d

# Run NodeJS server
$ node src/app.js
```

## Hasura configuring
- [Add **Default** data connector using **PG_DATABASE_URL** variable](https://hasura.io/docs/2.0/databases/data-connectors/adding-data-connectors/)
- Run **seed.sql** queries
- [Track all the foreign-keys of all tables in the database](https://hasura.io/docs/2.0/schema/postgres/using-existing-database/#to-track-all-the-foreign-keys-of-all-tables-in-the-database)
- [Configuring Permission Rules](https://hasura.io/docs/2.0/auth/authorization/permissions/)
- [Add computed field to Hasura metadata](https://hasura.io/docs/2.0/schema/postgres/computed-fields/#accessing-hasura-session-variables-in-computed-fields)
```bash
POST /v1/metadata HTTP/1.1
Content-Type: application/json
X-Hasura-Role: admin

{
    "type":"pg_add_computed_field",
    "args":{
        "source": "Default",
        "table":{
            "name":"images",
            "schema":"public"
        },
        "name":"author_sort",
        "definition":{
            "function":{
                "name":"image_author_sort",
                "schema":"public"
            },
            "table_argument":"image_row",
            "session_argument":"hasura_session"
        }
    }
}
```
- [Define needed Actions](https://hasura.io/docs/2.0/actions/quickstart/)

## Query examples

### Find images by tags with custom author sort:
```bash
query MyQuery {
  images(
    order_by: {
      author_sort: desc
    },
    where: {
      image_tags: {
        tag_value: {
          _in: ["tag1","tag5"]
        }
      }
    }
  ) {
    id
    url
    author_sort
    author_id
    collection_id
    created_at
    status
    author_sort
    image_tags {
      tag_value
    }
  }
}
```
