drop view if exists public.stream_comments;
create view public.stream_comments as (
    select created_utc, subreddit, author, body, permalink, parent_id, name, link_id, id
    from public.streamall
    order by created_utc desc, subreddit, author
);

drop view if exists public.stream_submissions;
create view public.stream_submissions as (
    select created_utc, subreddit, author, title, selftext, permalink, shortlink, name, thumbnail, url
    from public.stream_submissions_all
);

select max(created_utc)
from public.stream_comments

