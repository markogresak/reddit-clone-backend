# API Documentation

* [RedditClone.CommentController](#redditclonecommentcontroller)
  * [create](#redditclonecommentcontrollercreate)
  * [delete](#redditclonecommentcontrollerdelete)
  * [rate_comment](#redditclonecommentcontrollerrate_comment)
  * [show](#redditclonecommentcontrollershow)
  * [update](#redditclonecommentcontrollerupdate)
* [RedditClone.PostController](#redditclonepostcontroller)
  * [create](#redditclonepostcontrollercreate)
  * [delete](#redditclonepostcontrollerdelete)
  * [index](#redditclonepostcontrollerindex)
  * [rate_post](#redditclonepostcontrollerrate_post)
  * [show](#redditclonepostcontrollershow)
  * [update](#redditclonepostcontrollerupdate)
* [RedditClone.UserController](#redditcloneusercontroller)
  * [create](#redditcloneusercontrollercreate)
  * [delete](#redditcloneusercontrollerdelete)
  * [login](#redditcloneusercontrollerlogin)
  * [show](#redditcloneusercontrollershow)
  * [update](#redditcloneusercontrollerupdate)

## RedditClone.CommentController
### RedditClone.CommentController.create
#### creates and renders resource when data is valid
##### Request
* __Method:__ POST
* __Path:__ /api/comments
* __Request headers:__
```
content-type: multipart/mixed; charset: utf-8
```
* __Request body:__
```json
{
  "comment": {
    "text": "some content"
  }
}
```
##### Response
* __Status__: 201
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: tjph61aon0rrmd1t62vit3le0lj938df
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
location: /api/comments/2999
```
* __Response body:__
```json
{
  "data": {
    "user_id": null,
    "text": "some content",
    "rating": 0,
    "post_id": null,
    "id": 2999
  }
}
```

### RedditClone.CommentController.delete
#### deletes chosen resource
##### Request
* __Method:__ DELETE
* __Path:__ /api/comments/2997
##### Response
* __Status__: 204
* __Response headers:__
```
cache-control: max-age=0, private, must-revalidate
x-request-id: org7q9of35skleev5h77dqjodintojc3
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json

```

### RedditClone.CommentController.rate_comment
#### rate nonexistent comment
##### Request
* __Method:__ PUT
* __Path:__ /api/comments/0/rate?comment_rating[rating]=1
##### Response
* __Status__: 404
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: 62gsr38ca5kr1lrevanslu8ahna5src7
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "error": {
    "message": "Comment with id 0 not found."
  }
}
```

### RedditClone.CommentController.show
#### rate comment
##### Request
* __Method:__ GET
* __Path:__ /api/comments/2993
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: 62enisn6raugoi9pdiu6de0a81d7avl5
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "user_id": 19556,
    "text": "A comment",
    "rating": 1,
    "post_id": 6567,
    "id": 2993
  }
}
```

#### shows chosen resource
##### Request
* __Method:__ GET
* __Path:__ /api/comments/2998
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: trjbccniukdh2hkm8fdgrdstre5to2l1
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "user_id": 19573,
    "text": "A comment",
    "rating": 0,
    "post_id": 6572,
    "id": 2998
  }
}
```

### RedditClone.CommentController.update
#### updates and renders chosen resource when data is valid
##### Request
* __Method:__ PUT
* __Path:__ /api/comments/2996
* __Request headers:__
```
content-type: multipart/mixed; charset: utf-8
```
* __Request body:__
```json
{
  "comment": {
    "text": "some content"
  }
}
```
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: qrdj4qum27o8quq9ha3r5krf817kp6fu
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "user_id": 19566,
    "text": "some content",
    "rating": 0,
    "post_id": 6570,
    "id": 2996
  }
}
```

## RedditClone.PostController
### RedditClone.PostController.create
#### creates and renders resource when data is valid
##### Request
* __Method:__ POST
* __Path:__ /api/posts
* __Request headers:__
```
content-type: multipart/mixed; charset: utf-8
```
* __Request body:__
```json
{
  "post": {
    "title": "some title",
    "text": "some content"
  }
}
```
##### Response
* __Status__: 201
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: ouqkdbv6nuodhrbdf0dgl7q4o40r9rb3
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
location: /api/posts/6556
```
* __Response body:__
```json
{
  "data": {
    "user_id": 19534,
    "url": null,
    "title": "some title",
    "text": null,
    "submitted_at": "2017-07-11T21:19:38.350851",
    "rating": 0,
    "id": 6556,
    "comments": [],
    "comment_count": 0
  }
}
```

### RedditClone.PostController.delete
#### deletes chosen resource
##### Request
* __Method:__ DELETE
* __Path:__ /api/posts/6554
##### Response
* __Status__: 204
* __Response headers:__
```
cache-control: max-age=0, private, must-revalidate
x-request-id: jkvariu2qsuq2pga8rp9sg2com3f16g6
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json

```

### RedditClone.PostController.index
#### lists all entries on index
##### Request
* __Method:__ GET
* __Path:__ /api/posts
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: ibmpupf0rp0e5g47d6bqh6jofn238tg2
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": []
}
```

### RedditClone.PostController.rate_post
#### rate nonexistent post
##### Request
* __Method:__ PUT
* __Path:__ /api/posts/0/rate?post_rating[rating]=1
##### Response
* __Status__: 404
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: ipkrs9gf1i3fj8n56fjrb75qjmm9c0tv
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "error": {
    "message": "Post with id 0 not found."
  }
}
```

### RedditClone.PostController.show
#### rate post
##### Request
* __Method:__ GET
* __Path:__ /api/posts/6549
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: 8m8erako9bksgotek0ajqrmv2b2145a1
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "user_id": 19518,
    "url": "http://example.com",
    "title": "Title of post with url",
    "text": null,
    "submitted_at": "2017-07-11T21:19:38.143961",
    "rating": 1,
    "id": 6549,
    "comments": [],
    "comment_count": 0
  }
}
```

#### shows post with a comment
##### Request
* __Method:__ GET
* __Path:__ /api/posts/6564
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: 2vu9ubkapflosfvd708ts6ss7rfrsrgo
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "user_id": 19548,
    "url": "http://example.com",
    "title": "Title of post with url",
    "text": null,
    "submitted_at": "2017-07-11T21:19:38.476166",
    "rating": 0,
    "id": 6564,
    "comments": [
      {
        "user_id": 19549,
        "text": "A comment",
        "rating": 0,
        "post_id": 6564,
        "id": 2991
      }
    ],
    "comment_count": 1
  }
}
```

### RedditClone.PostController.update
#### updates and renders chosen resource when data is valid
##### Request
* __Method:__ PUT
* __Path:__ /api/posts/6553
* __Request headers:__
```
content-type: multipart/mixed; charset: utf-8
```
* __Request body:__
```json
{
  "post": {
    "title": "some title",
    "text": "some content"
  }
}
```
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: ml6s6kobrtves25pj1fqvrigfnvisk7i
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "user_id": 19527,
    "url": "http://example.com",
    "title": "some title",
    "text": null,
    "submitted_at": "2017-07-11T21:19:38.232746",
    "rating": 0,
    "id": 6553,
    "comments": [],
    "comment_count": 0
  }
}
```

## RedditClone.UserController
### RedditClone.UserController.create
#### creates and renders resource when data is valid
##### Request
* __Method:__ POST
* __Path:__ /api/users
* __Request headers:__
```
content-type: multipart/mixed; charset: utf-8
```
* __Request body:__
```json
{
  "user": {
    "username": "some_user",
    "password": "pass123"
  }
}
```
##### Response
* __Status__: 201
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: dudjlgqoeob06kektnqboje3sf32paem
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
location: /api/users/19614
```
* __Response body:__
```json
{
  "data": {
    "username": "some_user",
    "posts": [],
    "id": 19614,
    "comments": []
  }
}
```

### RedditClone.UserController.delete
#### deletes chosen resource
##### Request
* __Method:__ DELETE
* __Path:__ /api/users/19612
##### Response
* __Status__: 204
* __Response headers:__
```
cache-control: max-age=0, private, must-revalidate
x-request-id: gl6vpr49et3fvo7vu9nm4e0lomk2sc5i
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json

```

### RedditClone.UserController.login
#### login
##### Request
* __Method:__ POST
* __Path:__ /api/login?password=pass1234&username=test_user103
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: vk0m3b4g4jl146eelddgn51me8hvnbh6
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjE5NjA5IiwiZXhwIjoxNTAyMzk5OTc4LCJpYXQiOjE0OTk4MDc5NzgsImlzcyI6IlJlZGRpdENsb25lIiwianRpIjoiMDY3MDFhOTAtNzBhYi00YzY4LThlN2MtMzMwNWU5ZDFiOTVhIiwicGVtIjp7fSwic3ViIjoiVXNlcjoxOTYwOSIsInR5cCI6ImFjY2VzcyJ9.mJ3UHfqZ6bK1uir_3o5NmM4z1fKNfEZ1GaAcjML5LzIShzYI5p1OsHhi3jBUTr_eCWsz5kOYMayukVc67_hTzA
```
* __Response body:__
```json
{
  "data": {
    "user": {
      "username": "test_user103",
      "id": 19609
    },
    "jwt": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjE5NjA5IiwiZXhwIjoxNTAyMzk5OTc4LCJpYXQiOjE0OTk4MDc5NzgsImlzcyI6IlJlZGRpdENsb25lIiwianRpIjoiMDY3MDFhOTAtNzBhYi00YzY4LThlN2MtMzMwNWU5ZDFiOTVhIiwicGVtIjp7fSwic3ViIjoiVXNlcjoxOTYwOSIsInR5cCI6ImFjY2VzcyJ9.mJ3UHfqZ6bK1uir_3o5NmM4z1fKNfEZ1GaAcjML5LzIShzYI5p1OsHhi3jBUTr_eCWsz5kOYMayukVc67_hTzA",
    "exp": 1502399978
  }
}
```

### RedditClone.UserController.show
#### shows chosen user who has added a post and commented
##### Request
* __Method:__ GET
* __Path:__ /api/users/19600
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: fvklrnl3e8mos69bipvdotgvf9nqh94j
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "username": "test_user95",
    "posts": [
      {
        "user_id": 19600,
        "url": null,
        "title": "Title of post with text",
        "submitted_at": "2017-07-11T21:19:38.857126",
        "rating": 0,
        "id": 6581,
        "comment_count": 1
      }
    ],
    "id": 19600,
    "comments": [
      {
        "user_id": 19600,
        "text": "A comment",
        "rating": 0,
        "post_id": 6581,
        "id": 3007
      }
    ]
  }
}
```

### RedditClone.UserController.update
#### updates and renders chosen resource when data is valid
##### Request
* __Method:__ PUT
* __Path:__ /api/users/19607
* __Request headers:__
```
content-type: multipart/mixed; charset: utf-8
```
* __Request body:__
```json
{
  "user": {
    "username": "some_user",
    "password": "pass123"
  }
}
```
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: u791dne6dgvtj67aq5td4p8122g075oq
access-control-allow-origin: *
access-control-expose-headers: 
access-control-allow-credentials: true
vary: 
```
* __Response body:__
```json
{
  "data": {
    "username": "some_user",
    "posts": [],
    "id": 19607,
    "comments": []
  }
}
```

