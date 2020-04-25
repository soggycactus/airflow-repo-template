drop view if exists public.users cascade;
create view public.users as (
    with users as (
        select distinct author, author_fullname, time_gathered::timestamptz
        from public.user_comments
        union
        select distinct author, author_fullname, null::timestamp as time_gathered
        from public.posts
        union
        select distinct author, author_fullname, null::timestamp as time_gathered
        from public.hot_scrapes
    )

    select author, author_fullname, max(time_gathered) as last_scraped
    from users
    where author is not null
      and author != ''
    group by author, author_fullname
    order by last_scraped desc nulls last
);

drop view if exists public.subreddits cascade;
create view public.subreddits as (
    with subreddits as (
        select distinct subreddit, subreddit_id, null::timestamp as time_gathered
        from public.user_comments
        union
        select distinct subreddit, subreddit_id, null::timestamp as time_gathered
        from public.posts
        union
        select distinct subreddit, subreddit_id, time_gathered::timestamptz
        from public.hot_scrapes
        where subreddit is not null and subreddit != ''
    )

    select subreddit, subreddit_id, max(time_gathered) as time_gathered
    from subreddits
    group by subreddit, subreddit_id
    order by time_gathered desc nulls last
);


drop view if exists public.user_subreddits cascade;
create view public.user_subreddits as (
    with user_subreddits as (
        select distinct subreddit, author
        from user_comments
        union
        select distinct subreddit, author
        from posts
        union
        select distinct subreddit, author
        from hot_scrapes
    )

    select *
    from user_subreddits
    order by subreddit
);


drop view if exists public.all_posts cascade;
create view public.all_posts as (
    with all_posts_sub as (
        select distinct time_gathered, link_id, id, name, parent_id, created, created_utc, submission, subreddit, score, author, body, ups, permalink, true as from_posts
        from posts
        union
        select distinct time_gathered, link_id, id, name, parent_id, created, created_utc, submission, subreddit, score, author, body, ups, permalink,false as from_posts
        from user_comments
        union
        select distinct time_gathered, link_id, id, name, parent_id, created, created_utc, submission, subreddit, score, author, body, ups, permalink,false as from_posts
        from hot_scrapes
    )

    select *
    from all_posts_sub
    where link_id is not null and id is not null and name is not null and parent_id is not null and link_id != ''
);

drop view if exists public.user_counts cascade;
create view public.user_counts as (
    select count(distinct author) as n_users
    from public.users
);

drop view if exists public.subreddit_counts cascade;
create view public.subreddit_counts as (
    select count(distinct subreddit) as n_subreddits
    from public.subreddits
);

drop view if exists public.comment_count cascade;
create view public.comment_count as (
    select count(*) as n_posts
    from public.all_posts
);

drop view if exists public.phone_numbers cascade;
create view public.phone_numbers as (
    select *
    from (
         select body similar to '%[0-9]{3}-[0-9]{3}-[0-9]{4}%' as has_phone, *
         from all_posts
             ) x
    where has_phone
);

drop view if exists public.emails cascade;
create view public.emails as (
    select *
    from all_posts
    where body ilike 'my email is' or
          body ilike '%email me%' and
          body similar to '%@%'
);

drop view if exists public.nsfw_rating cascade;
create view public.nsfw_rating as (
    with over_eighteen as (
        select subreddit, over_18, count(*) as n_obs
        from user_comments
        group by subreddit, over_18
        order by subreddit, over_18
    ),
     true_eighteen as (
         select *
         from over_eighteen
         where over_18 = 'TRUE'
     ),
     false_eightneed as (
         select *
         from over_eighteen
         where over_18 = 'FALSE'
     ),
     data_for_summary as (
         select case when te.subreddit is null then fe.subreddit else te.subreddit end as subreddit,
                case when te.n_obs is null then 0 else te.n_obs::numeric end as true_count,
                case when fe.n_obs is null then 0 else fe.n_obs::numeric end as false_count
         from true_eighteen te
                  full join false_eightneed fe on fe.subreddit = te.subreddit
     )

    select *, true_count + false_count as total_obs, round(true_count / (true_count + false_count), 2) as pct_nsfw
    from data_for_summary
    order by subreddit
);

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


drop view if exists public.stream_authors;
create view public.stream_authors as (
    with mapping_data as (
        select subreddit, author
        from public.stream_submissions_all
        union all
        select subreddit, author
        from public.stream_comments
    )

    select subreddit, author, count(*) as n_observations
    from mapping_data
    group by subreddit, author
    order by subreddit, author

);

