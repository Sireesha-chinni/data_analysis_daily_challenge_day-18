use dailychallenges_2;

create table users (
user_id int primary key,
username varchar(50),
email varchar(30),
join_data date 
);

create table posts (
post_id int primary key,
user_id int ,
content text,
post_date datetime,
foreign key (user_id) references users(user_id)
);

create table likes (
like_id int primary key,
user_id int ,
post_id int,
like_date datetime,
foreign key (post_id) references posts(post_id),
foreign key (user_id) references users(user_id)
);

create table comments(
comment_id int primary key,
post_id int,
user_id int,
comment_text text,
comment_date datetime,
foreign key (post_id) references posts(post_id),
foreign key (user_id) references users(user_id)
);

create table friendships(
friendship_id int primary key,
user_id1 int,
user_id2 int,
since_date date,
foreign key (user_id1) references users(user_id),
foreign key (user_id2) references users(user_id)
);

-- Task 1:
-- 1. Retrieve all posts along with the username of the author.

select u.username,p.* from posts p
left join users u 
on u.user_id = p.user_id;


-- 2.Find all comments on each post along with the commenter’s username.

select c.*,u.username from comments c
left join users u
on c.user_id = u.user_id;

-- Task 2:
-- 3. Find the top 3 users with the most posts.

select u.username, p.user_id,count(p.post_id) as num_of_posts from 
users u join posts p
on p.user_id = u.user_id
group by p.user_id
order by num_of_posts desc
limit 3;

-- 4. Retrieve posts that have more likes than the average number of likes per post.


select post_id, count(like_id) as like_count
from likes
group by post_id
having like_count > ( select avg(t.like_counts) 
from (select count(like_id) as like_counts from likes
group by post_id) as t);



-- 5. Find users who have never posted anything but have liked posts.

select * from users 
where user_id in (select user_id from likes) and
user_id not in (select user_id from posts);

-- Task 3:
-- 6. Get a list of all friends of a specific user (say user_id = 3).

SELECT u.user_id, u.username, u.email, f.since_date
FROM Friendships f
JOIN Users u
  ON u.user_id = CASE 
                   WHEN f.user_id1 = 3 THEN f.user_id2
                   ELSE f.user_id1
                 END
WHERE f.user_id1 = 3 OR f.user_id2 = 3;



-- 7. Retrieve posts that were liked by friends of a given user (nested join scenario).

select distinct p.*
from likes l
join posts p on p.post_id = l.post_id
where l.user_id in (
    select user_id2 from friendships where user_id1 = 3
    union
    select user_id1 from friendships where user_id2 = 3
);


-- Task 4:
-- 8. Create a stored procedure GetUserActivity(userId) that returns:
-- o Total posts by the user
-- o Total likes given by the user
-- o Total likes received on the user’s posts
-- o Total comments made by the user

delimiter $$ 

create procedure GetUserActivity(in userId int)

begin
	select  (select  count(*) from posts where user_id = userId) as total_posts,
    (select count(*) from likes where user_id = userId) as total_Likes,
    (select count(*) from comments where user_id = userId ) as total_comments,
    (select count(*) from likes l
         join posts p on p.post_id = l.post_id
         where p.user_id = userId) as likes_received;

end $$

delimiter ;

call GetUserActivity(3);

-- Task 5: Challenge Query
-- 9. Find the most influential user (the user whose posts have the highest total likes +
-- comments).

select p.user_id, u.username,
       (select count(*) from likes l where l.post_id in
            (select post_id from posts where user_id = p.user_id))
     + (select count(*) from comments c where c.post_id in
            (select post_id from posts where user_id = p.user_id)) as total_engagement
from posts p
join users u on u.user_id = p.user_id
group by p.user_id, u.username
order by total_engagement desc
limit 1;
 
 

 