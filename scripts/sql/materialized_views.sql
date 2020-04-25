-- drop materialized view if exists public.mat_stream_authors;
create materialized view public.mat_stream_authors as (
    select *
    from public.stream_authors
);

create materialized view public.mat_comments_by_second as (
    select created_utc, count(*) as n_observations
    from public.stream_comments
    group by created_utc
    order by created_utc desc
);
