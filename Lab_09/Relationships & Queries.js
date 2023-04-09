

// Creating a Customer node
CREATE (:Customer {customer_id: 1, name: 'MAK', phone_no: '12345678', age: 21, gender: 'male', country: 'BD'})

// Creating a Genre node
CREATE (:Genre {genre_id: 1, name: 'Fiction'})

// Create an Author node
CREATE (:Author {author_id: 1, name: 'Author MAK', country: 'UK', date_of_birth: '1995-07-31'})

// Create a Book node
CREATE (:Book {book_id: 1, title: 'MAK book', published_year: 2007, language: 'English', page_count: 223, price: 29.55})
CREATE (:Book {book_id: 2, title: 'MAK book 2', published_year: 2009, language: 'English', page_count: 653, price: 99.55})
CREATE (:Book {book_id: 3, title: 'MAK book 3', published_year: 2011, language: 'English', page_count: 573, price: 299.99})


// Create a relationship between a Customer and a Book
MATCH (c:Customer {customer_id: 1}), (b:Book {book_id: 1})
CREATE (c)-[:Purchased {purchasing_date: '2002-03-15', amount: 10.99}]->(b)

MATCH (c:Customer {customer_id: 1}), (b:Book {book_id: 2})
CREATE (c)-[:Purchased {purchasing_date: '2002-01-01', amount: 29.55}]->(b)

MATCH (c:Customer {customer_id: 1}), (b:Book {book_id: 3})
CREATE (c)-[:Purchased {purchasing_date: '2022-03-15', amount: 299.99}]->(b)


// A Customer can rate a book
MATCH (c:Customer), (b:Book)
WHERE c.customer_id = 1 AND b.book_id = 1
CREATE (c)-[:Rated {rating: 8}]->(b)


// Create a relationship between a Customer and an Author
MATCH (c:Customer {customer_id: 1}), (a:Author {author_id: 1})
CREATE (c)-[: Rating {rating: 4}]->(a)



// Create a relationship between a Book and a Genre
MATCH (b:Book {book_id: 1}), (g:Genre {genre_id: 1})
CREATE (b)-[: Belongs_to ]->(g)




// Create a relationship between volumes of a Book
MATCH (b1:Book {book_id: 1}), (b2:Book {book_id: 2})
CREATE (b2)-[: Volume_of ]-> (b1)




// Create a relationship between author's writing date and a Book
MATCH (b:Book {book_id: 1}), (a:Author {author_id: 1})
CREATE (a)-[: Writing_Year {writing_year: 2006} ]-> (b)




// a
MATCH (c:Customer)-[p:Purchased]->(b:Book)
RETURN b.title, SUM(p.amount) AS total_revenue
ORDER BY total_revenue DESC

// b
MATCH (c:Customer)-[r:Rated]->(b:Book)-[:Belongs_to]->(g:Genre)
RETURN g.name AS genre, AVG(r.rating) AS average_rating


// c
MATCH (c:Customer)-[:Purchased]->(b:Book)
WHERE c.name = 'MAK' AND b.purchasing_date >= date('2000-01-01') AND b.purchasing_date <= date('2023-12-31')
RETURN c.name, b.title

MATCH (c:Customer {customer_id: 1})-[:Purchased]->(b:Book)
WHERE b.purchasing_date >= date('2002-01-01') AND b.purchasing_date <= date('2022-03-15')
RETURN c.name, b.title


// d
MATCH (c:Customer)-[:Purchased]->(b:Book)
WITH c, COUNT(b) AS num_books
ORDER BY num_books DESC
LIMIT 1
RETURN c.name, num_books

MATCH (c:Customer)-[:Purchased]->(b:Book)
WITH c.customer_id AS customer_id, COUNT(b) AS num_books
ORDER BY num_books DESC 
LIMIT 1
MATCH (c:Customer {customer_id: customer_id})
RETURN c.name, num_books


// e
MATCH (b:Book)<-[:Purchased]-(:Customer)
RETURN b.title, COUNT(*) AS num_purchases
ORDER BY num_purchases DESC
LIMIT 1


// f
MATCH (c:Customer)-[r:Rated]->(b:Book)    // just rated
WHERE b.title = 'MAK book'
RETURN c.name, r.rating

MATCH (c:Customer)-[:Purchased]->(b:Book {title: 'MAK book'})   // just bought
RETURN c.name, b.title

MATCH (c:Customer)-[r]-(b:Book)
WHERE b.title = 'MAK book' AND (type(r) = 'Purchased' OR type(r) = 'Rated')   // for both 
RETURN c.name, type(r), b.title, r.rating


// g
MATCH (c:Customer)-[:Purchased]->(b:Book)-[:Volume_of*0..1]->(:Book)<-[:Writing_Year]-(a:Author {name: 'Author MAK'})
RETURN c.name, collect(b.title) AS purchased_books


// h
MATCH (b1:Book)-[:Purchased]->(c:Customer)-[:Purchased]->(b2:Book)
WHERE b1.book_id < b2.book_id
WITH collect(distinct b1.book_id) as b1_ids, collect(distinct b2.book_id) as b2_ids, count(distinct c.customer_id) as freq
WHERE freq > 1
RETURN b1_ids, b2_ids, freq
ORDER BY freq DESC

MATCH (b1:Book)-[:Purchased]->(c:Customer)<-[:Purchased]-(b2:Book)
WHERE b1 <> b2
WITH b1, b2, count(DISTINCT c) AS freq
WHERE freq > 1
RETURN b1.title, b2.title, freq
ORDER BY freq DESC;
