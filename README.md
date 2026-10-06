# Day 18 –ConnectHub: Social Media Data Analysis (SQL Challenge)

A SQL coding challenge where I act as a Database Analyst for **ConnectHub**, a fictional social media platform. The goal is to query user, post, like, comment, and friendship data to get insights about user activity and relationships, using **joins, subqueries, and stored procedures**.

- **Database:** MySQL
- **Schema name:** `dailychallenges_2`
- **Challenge brief:** `Day7_Social_media.pdf`

## Files

| File | Purpose |
|---|---|
| `day_18_data_analytics_daily_challenge.sql` | Table creation + solutions to all 9 tasks |
| `social_media_dataset.sql` | Schema fixes + sample data (20 users, 40 posts, 60 likes, 50 comments, 25 friendships) |
| `Day7_Social_media.pdf` | Original problem statement |

## Database Schema

```
Users (user_id PK, username, email, join_date)
   │
   ├──< Posts (post_id PK, user_id FK, content, post_date)
   │       │
   │       ├──< Likes (like_id PK, user_id FK, post_id FK, like_date)
   │       └──< Comments (comment_id PK, post_id FK, user_id FK, comment_text, comment_date)
   │
   └──< Friendships (friendship_id PK, user_id1 FK, user_id2 FK, since_date)
```

Each friendship is stored **once**, so a user can appear in either `user_id1` or `user_id2`.

## How to Run

1. Open MySQL Workbench (or any MySQL client).
2. Run the table creation section of `day_18_data_analytics_daily_challenge.sql` (everything above "Task 1").
3. Run `social_media_dataset.sql`. It fixes two schema issues, then loads the data:
   - renames `join_data` to `join_date` (typo in the original table)
   - widens `email` from `varchar(30)` to `varchar(50)`
4. Run the task queries in `day_18_data_analytics_daily_challenge.sql`.

> **Insert order matters.** Because of foreign keys, data must be inserted in this order: `users` → `posts` → `likes` / `comments` / `friendships`. Otherwise MySQL raises **Error 1452** (foreign key constraint fails).

## Tasks and Approach

### Task 1: Joins
| # | Question | Approach |
|---|---|---|
| 1 | All posts with the author's username | `posts` joined to `users` on `user_id` |
| 2 | All comments with the commenter's username | `comments` joined to `users` on `user_id` |

### Task 2: Aggregation and Subqueries
| # | Question | Approach |
|---|---|---|
| 3 | Top 3 users with the most posts | `JOIN` + `GROUP BY` + `ORDER BY COUNT DESC` + `LIMIT 3` |
| 4 | Posts with more likes than the average | `HAVING` compared against a nested subquery that averages per-post like counts |
| 5 | Users who never posted but have liked posts | `user_id IN (likes)` and `user_id NOT IN (posts)` |

### Task 3: Friendships
| # | Question | Approach |
|---|---|---|
| 6 | All friends of user 3 | `CASE` picks the *other* user in each friendship row |
| 7 | Posts liked by friends of a given user | Friend IDs gathered with `UNION` of both columns, used inside `IN` |

### Task 4: Stored Procedure
**8. `GetUserActivity(userId)`** returns one row with:
- `total_posts`: posts written by the user
- `total_Likes`: likes given by the user
- `total_comments`: comments made by the user
- `likes_received`: likes on the user's posts

```sql
CALL GetUserActivity(3);
```

### Task 5: Challenge Query
**9. Most influential user:** the user whose posts received the highest **likes + comments** combined. Uses correlated scalar subqueries to count likes and comments on each author's posts, then orders by the total and takes the top row.

## Concepts Demonstrated

- `INNER JOIN` and `LEFT JOIN`
- Scalar, correlated, and nested subqueries
- `GROUP BY`, `HAVING`, and multiple aggregates
- `IN` / `NOT IN` filtering
- `UNION` and `CASE` expressions
- Stored procedures with `IN` parameters and custom delimiters

## Notes and Possible Improvements

- **Query 3** selects `username` without grouping by it. This fails when `ONLY_FULL_GROUP_BY` is enabled (the MySQL default). Use `GROUP BY u.user_id, u.username`.
- **Query 5** uses `NOT IN`, which returns no rows if `posts.user_id` ever contains `NULL`. `NOT EXISTS` is the safer option.
- **Query 9** returns only one row, so ties for "most influential" are not shown.
- **Query 4** averages only over posts that have at least one like. Posts with zero likes are not counted.
- For larger datasets, add indexes on foreign key columns used in joins and filters (`posts.user_id`, `likes.post_id`, `likes.user_id`, `comments.post_id`).

```sql
CREATE INDEX idx_likes_post ON likes(post_id);
CREATE INDEX idx_comments_post ON comments(post_id);
```

## Author

Day 18 of my Data Analytics daily challenge series.
