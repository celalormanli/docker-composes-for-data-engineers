-- Fake e-commerce dataset: customers, products, orders, order_items

CREATE TABLE customers (
    customer_id serial PRIMARY KEY,
    first_name  text NOT NULL,
    last_name   text NOT NULL,
    email       text NOT NULL UNIQUE,
    country     text NOT NULL,
    created_at  timestamptz NOT NULL
);

CREATE TABLE products (
    product_id serial PRIMARY KEY,
    name       text NOT NULL,
    category   text NOT NULL,
    price      numeric(10, 2) NOT NULL,
    in_stock   integer NOT NULL
);

CREATE TABLE orders (
    order_id    serial PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customers (customer_id),
    status      text NOT NULL,
    ordered_at  timestamptz NOT NULL
);

CREATE TABLE order_items (
    order_item_id serial PRIMARY KEY,
    order_id      integer NOT NULL REFERENCES orders (order_id),
    product_id    integer NOT NULL REFERENCES products (product_id),
    quantity      integer NOT NULL,
    unit_price    numeric(10, 2) NOT NULL
);

-- 2,000 customers
INSERT INTO customers (first_name, last_name, email, country, created_at)
SELECT
    (ARRAY['James','Mary','John','Patricia','Robert','Jennifer','Michael','Linda','David','Elizabeth',
           'William','Susan','Richard','Jessica','Joseph','Sarah','Thomas','Karen','Ayse','Mehmet'])[1 + floor(random() * 20)],
    (ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez',
           'Hernandez','Lopez','Wilson','Anderson','Yilmaz','Kaya','Demir','Celik','Sahin','Ozturk'])[1 + floor(random() * 20)],
    'user_' || gs || '@example.com',
    (ARRAY['USA','Germany','Turkey','France','UK','Netherlands','Spain','Italy','Brazil','Japan'])[1 + floor(random() * 10)],
    now() - (random() * interval '730 days')
FROM generate_series(1, 2000) AS gs;

-- 300 products
INSERT INTO products (name, category, price, in_stock)
SELECT
    (ARRAY['Wireless','Smart','Portable','Classic','Premium','Eco','Pro','Ultra','Mini','Compact'])[1 + floor(random() * 10)]
        || ' '
        || (ARRAY['Headphones','Keyboard','Mouse','Monitor','Speaker','Lamp','Backpack','Bottle','Notebook','Charger',
                  'Camera','Tablet','Watch','Router','Microphone'])[1 + floor(random() * 15)]
        || ' #' || gs,
    (ARRAY['Electronics','Accessories','Office','Home','Outdoor','Audio'])[1 + floor(random() * 6)],
    round((5 + random() * 495)::numeric, 2),
    floor(random() * 1000)
FROM generate_series(1, 300) AS gs;

-- 10,000 orders
INSERT INTO orders (customer_id, status, ordered_at)
SELECT
    1 + floor(random() * 2000),
    (ARRAY['pending','paid','shipped','delivered','cancelled'])[1 + floor(random() * 5)],
    now() - (random() * interval '365 days')
FROM generate_series(1, 10000);

-- 1-5 items per order (~30,000 rows)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.order_id,
    1 + floor(random() * 300),
    1 + floor(random() * 5),
    round((5 + random() * 495)::numeric, 2)
FROM orders AS o
-- o.order_id * 0 forces per-row evaluation of random(); otherwise it is folded once
CROSS JOIN LATERAL generate_series(1, 1 + (o.order_id * 0) + floor(random() * 5)::int);

CREATE INDEX idx_orders_customer_id ON orders (customer_id);
CREATE INDEX idx_orders_ordered_at ON orders (ordered_at);
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_order_items_product_id ON order_items (product_id);

ANALYZE;
