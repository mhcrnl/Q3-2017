#!/bin/bash
GET https://www.googleapis.com/blogger/v3/blogs/2399953?key=AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8

GET https://www.googleapis.com/blogger/v3/blogs/byurl?url=https://perlworldromania.blogspot.ro/

GET https://www.googleapis.com/blogger/v3/blogs/2399953/posts?key=AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8

GET https://perlworldromania.blogspot.ro/v3/blogs/2399953/posts?key=AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8

GET https://perlworldromania.blogspot.ro?key=AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8

GET https://www.googleapis.com/blogger/v3/blogs/blogId

GET https://perlworldromania.blogspot.ro/blogger/v3/blogs/blogId=6664001403810789524

GET https://www.googleapis.com/blogger/v3/blogs/perlworldromania.blogspot.ro
{
 "error": {
  "errors": [
   {
    "domain": "usageLimits",
    "reason": "dailyLimitExceededUnreg",
    "message": "Daily Limit for Unauthenticated Use Exceeded. Continued use requires signup.",
    "extendedHelp": "https://code.google.com/apis/console"
   }
  ],
  "code": 403,
  "message": "Daily Limit for Unauthenticated Use Exceeded. Continued use requires signup."
 }
}
[mhcrnl@localhost ~]$ 
GET https://www.googleapis.com/blogger/v3/blogs/blogId=6664001403810789524
{
 "error": {
  "errors": [
   {
    "domain": "usageLimits",
    "reason": "dailyLimitExceededUnreg",
    "message": "Daily Limit for Unauthenticated Use Exceeded. Continued use requires signup.",
    "extendedHelp": "https://code.google.com/apis/console"
   }
  ],
  "code": 403,
  "message": "Daily Limit for Unauthenticated Use Exceeded. Continued use requires signup."
 }
}
GET https://www.googleapis.com/blogger/v3/blogs/6664001403810789524?key=AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8
{
 "kind": "blogger#blog",
 "id": "6664001403810789524",
 "name": "Perl World Romania",
 "description": "Noutați despre limbajul de programare PERL ",
 "published": "2014-06-21T09:39:24+03:00",
 "updated": "2017-10-13T10:07:21+03:00",
 "url": "http://perlworldromania.blogspot.com/",
 "selfLink": "https://www.googleapis.com/blogger/v3/blogs/6664001403810789524",
 "posts": {
  "totalItems": 13,
  "selfLink": "https://www.googleapis.com/blogger/v3/blogs/6664001403810789524/posts"
 },
 "pages": {
  "totalItems": 1,
  "selfLink": "https://www.googleapis.com/blogger/v3/blogs/6664001403810789524/pages"
 },
 "locale": {
  "language": "ro",
  "country": "",
  "variant": ""
 }
}
GET https://www.googleapis.com/blogger/v3/users/6664001403810789524/blogs
{
 "error": {
  "errors": [
   {
    "domain": "global",
    "reason": "required",
    "message": "Login Required",
    "locationType": "header",
    "location": "Authorization"
   }
  ],
  "code": 401,
  "message": "Login Required"
 }
}
GET https://www.googleapis.com/blogger/v3/users/6664001403810789524/perlworldromania.blogspot.ro

GET https://www.googleapis.com/blogger/v3/blogs/6664001403810789524/posts?key=AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8
"author": {
    "id": "g113041622386205770526",
    "displayName": "Mihai C",
    "url": "https://www.blogger.com/profile/13332304523445848778",
    "image": {
     "url": "//lh5.googleusercontent.com/-YUe2OLJ8vIE/AAAAAAAAAAI/AAAAAAAAAAA/8DdG3YY8AH0/s35-c/photo.jpg"
    }
   },
   "replies": {
    "totalItems": "0",
    "selfLink": "https://www.googleapis.com/blogger/v3/blogs/6664001403810789524/posts/2245324688696605738/comments"
   },
   "labels": [
    "atelier"
   ]
  }
 ],
 "etag": "\"h3p"
 
 GET https://www.googleapis.com/blogger/v3/blogs/6664001403810789524/posts/13332304523445848778?key=AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8
 {
 "error": {
  "errors": [
   {
    "domain": "global",
    "reason": "required",
    "message": "Required"
   }
  ],
  "code": 400,
  "message": "Required"
 }
}
POST https://www.googleapis.com/blogger/v3/blogs/6664001403810789524/posts/
Authorization: AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8
Content-Type: application/json

{
  "kind": "blogger#post",
  "blog": {
    "id": "6664001403810789524"
  },
  "title": "A new post",
  "content": "With <b>exciting</b> content..."
}
