-- crear la base de datos --
CREATE DATABASE desafio3_victor_gonzalez_221;
--acceder a la base de datos--
\c desafio3_victor_gonzalez_221
-- crear la tabla users--
CREATE TABLE users(
  id SERIAL,
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  rol VARCHAR
);

-- ingresar datos a la tabla  users--
INSERT INTO users(email, name, last_name, rol) VALUES
('juan@mail.com', 'juan', 'perez', 'administrador'),
('diego@mail.com', 'diego', 'munoz', 'usuario'),
('maria@mail.com', 'maria', 'meza', 'usuario'),
('roxana@mail.com','roxana', 'diaz', 'usuario'),
('pedro@mail.com', 'pedro', 'diaz', 'usuario');

-- crear la tabla posts--
CREATE TABLE posts(
  id SERIAL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  outstanding BOOLEAN NOT NULL DEFAULT FALSE,
  user_id BIGINT
);

-- ingresar datos a la tabla  posts--
INSERT INTO posts (title, content, created_at,
updated_at, outstanding, user_id) VALUES
('prueba', 'contenido prueba', '01/01/2021', '01/02/2021', true, 1),
('prueba2', 'contenido prueba2', '01/03/2021', '01/03/2021', true, 1),
('ejercicios', 'contenido ejercicios', '02/05/2021', '03/04/2021', true, 2),
('ejercicios2', 'contenido ejercicios2', '03/05/2021', '04/04/2021', false, 2),
('random', 'contenido random', '03/06/2021', '04/05/2021', false, null);

-- crear la tabla comments--
CREATE TABLE comments(
  id SERIAL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  user_id BIGINT,
  post_id BIGINT
);

-- ingresar datos a la tabla  comments--
INSERT INTO comments (content, created_at, user_id,
post_id) VALUES
('comentario 1', '03/06/2021', 1, 1),
('comentario 2', '03/06/2021', 2, 1),
('comentario 3', '04/06/2021', 3, 1),
('comentario 4', '04/06/2021', 1, 2);

--Cruza los datos de la tabla usuarios y posts mostrando las siguientes columnas.
--nombre e email del usuario junto al título y contenido del post--

SELECT users.name, users.email, posts.title, posts.content FROM users JOIN posts ON users.id = posts.user_id;
/*
 name  |     email      |    title    |        content
-------+----------------+-------------+-----------------------
 juan  | juan@mail.com  | prueba      | contenido prueba
 juan  | juan@mail.com  | prueba2     | contenido prueba2
 diego | diego@mail.com | ejercicios  | contenido ejercicios
 diego | diego@mail.com | ejercicios2 | contenido ejercicios2

 */

--Muestra el id, título y contenido de los posts de los administradores. El administrador--
--puede ser cualquier id y debe ser seleccionado dinámicamente--

SELECT posts.id, posts.title, posts.content FROM posts JOIN users ON posts.user_id = users.id WHERE users.rol = 'administrador';
/*
 id |  title  |      content
----+---------+-------------------
  1 | prueba  | contenido prueba
  2 | prueba2 | contenido prueba2
*/

--Cuenta la cantidad de posts de cada usuario. La tabla resultante debe mostrar el id y --
--email del usuario junto con la cantidad de posts de cada usuario--

SELECT users.id , users.email, COUNT(posts) FROM posts RIGHT JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY users.id ASC;

/*
 id |      email      | count
----+-----------------+-------
  1 | juan@mail.com   |     2
  2 | diego@mail.com  |     2
  3 | maria@mail.com  |     0
  4 | roxana@mail.com |     0
  5 | pedro@mail.com  |     0
*/
--Muestra el email del usuario que ha creado más posts. Aquí la tabla resultante tiene--
--un único registro y muestra solo el email.--

SELECT users.email FROM posts JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY COUNT(posts.id) DESC LIMIT 1;

/*
     email
----------------
 diego@mail.com
*/
--Muestra la fecha del último post de cada usuario.--

SELECT users.name, MAX(created_at) FROM posts JOIN users ON posts.user_id = users.id GROUP BY posts.user_id,users.name;

/*
 name  |         max
-------+---------------------
 diego | 2021-05-03 00:00:00
 juan  | 2021-03-01 00:00:00
*/
--Muestra el título y contenido del post (artículo) con más comentarios.--

SELECT posts.title,posts.content FROM comments JOIN posts ON comments.post_id = posts.id GROUP BY comments.post_id, posts.title, posts.content order by post_id asc limit 1;

/*
 title  |     content
--------+------------------
 prueba | contenido prueba
*/
--Muestra en una tabla el título de cada post, el contenido de cada post y el contenido--
--de cada comentario asociado a los posts mostrados, junto con el email del usuario que lo escribió.--

SELECT posts.title,posts.content,comments.content AS posts_comments_association ,users.email FROM posts JOIN comments ON posts.id = comments.post_id JOIN users ON comments.user_id = users.id;

/*
  title  |      content      | posts_comments_association |     email
---------+-------------------+----------------------------+----------------
 prueba  | contenido prueba  | comentario 1               | juan@mail.com
 prueba  | contenido prueba  | comentario 2               | diego@mail.com
 prueba  | contenido prueba  | comentario 3               | maria@mail.com
 prueba2 | contenido prueba2 | comentario 4               | juan@mail.com
*/
--Muestra el contenido del último comentario de cada usuario.--

WITH max_comments_table AS (SELECT MAX(comments.id) as max_comments_id FROM comments GROUP BY user_id) SELECT comments.created_at, comments.content, comments.user_id FROM comments JOIN max_comments_table on comments.id = max_comments_table.max_comments_id order by comments.user_id;

/*
     created_at      |   content    | user_id
---------------------+--------------+---------
 2021-06-04 00:00:00 | comentario 4 |       1
 2021-06-03 00:00:00 | comentario 2 |       2
 2021-06-04 00:00:00 | comentario 3 |       3
*/
--Muestra los emails de los usuarios que no han escrito ningún comentario.--

SELECT users.email FROM comments RIGHT JOIN users ON comments.user_id = users.id GROUP BY comments.content,users.email  HAVING comments.content IS NULL;

/*
      email
-----------------
 pedro@mail.com
 roxana@mail.com
*/


             --tablas--


 --comments--
 id |   content    |     created_at      | user_id | post_id
----+--------------+---------------------+---------+---------
  1 | comentario 1 | 2021-06-03 00:00:00 |       1 |       1
  2 | comentario 2 | 2021-06-03 00:00:00 |       2 |       1
  3 | comentario 3 | 2021-06-04 00:00:00 |       3 |       1
  4 | comentario 4 | 2021-06-04 00:00:00 |       1 |       2

 --posts--
id |    title    |        content        |     created_at      |     updated_at      | outstanding | user_id
---+-------------+-----------------------+---------------------+---------------------+-------------+---------
 1 | prueba      | contenido prueba      | 2021-01-01 00:00:00 | 2021-02-01 00:00:00 | t           |       1
 2 | prueba2     | contenido prueba2     | 2021-03-01 00:00:00 | 2021-03-01 00:00:00 | t           |       1
 3 | ejercicios  | contenido ejercicios  | 2021-05-02 00:00:00 | 2021-04-03 00:00:00 | t           |       2
 4 | ejercicios2 | contenido ejercicios2 | 2021-05-03 00:00:00 | 2021-04-04 00:00:00 | f           |       2
 5 | random      | contenido random      | 2021-06-03 00:00:00 | 2021-05-04 00:00:00 | f           |

  --users--
 id |      email      |  name  | last_name |      rol
----+-----------------+--------+-----------+---------------
  1 | juan@mail.com   | juan   | perez     | administrador
  2 | diego@mail.com  | diego  | munoz     | usuario
  3 | maria@mail.com  | maria  | meza      | usuario
  4 | roxana@mail.com | roxana | diaz      | usuario
  5 | pedro@mail.com  | pedro  | diaz      | usuario
