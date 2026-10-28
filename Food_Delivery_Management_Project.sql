create database food_delivery_management;
use food_delivery_management;

create table customers(
	customer_id varchar(20) primary key ,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    email varchar(100) ,
    phone VARCHAR(20) ,
    gender VARCHAR(20),
    date_of_birth DATE,
    registration_date DATE,
    city VARCHAR(50) ,
    state VARCHAR(50) ,
    pincode VARCHAR(10),
	customer_status VARCHAR(20),
	preferred_payment_method VARCHAR(20)
);
create table restaurants(
	restaurant_id VARCHAR(20) primary key,
	restaurant_name VARCHAR(100) not null,
	cuisine_type VARCHAR(50),
	city VARCHAR(50),
	state VARCHAR(50),
	rating DECIMAL(2,1),
	price_range VARCHAR(30),
	opening_time TIME,
	closing_time TIME,
	restaurant_status VARCHAR(20)
);

create table menu_items(
	menu_item_id VARCHAR(20) primary key,
	restaurant_id VARCHAR(20),
	item_name VARCHAR(100) not null,
	cuisine_type VARCHAR(50),
	item_category VARCHAR(50),
	price DECIMAL(10,2),
	preparation_time INT,
	vegetarian VARCHAR(10),
	availability VARCHAR(20),
	item_status VARCHAR(20),
    constraint r_id_chk2 foreign key(restaurant_id) references restaurants(restaurant_id)
);

create table orders(
	order_id VARCHAR(20) primary key,
	customer_id VARCHAR(20),
	restaurant_id VARCHAR(20),
	order_date DATE,
	order_time TIME ,
	delivery_address VARCHAR(255),
	payment_method VARCHAR(50),
	payment_status VARCHAR(30),
	order_status VARCHAR(30),
	delivery_status VARCHAR(30),
	delivery_partner_name VARCHAR(100),
	discount_amount DECIMAL(10,2),
	total_amount DECIMAL(10,2),
    constraint c_id_chk foreign key(customer_id) references customers(customer_id),
    constraint r_id_chk foreign key(restaurant_id) references restaurants(restaurant_id)
    
);	


create table order_items(
	order_item_id VARCHAR(20) primary key,
	order_id VARCHAR(20),
	menu_item_id VARCHAR(20),
	quantity INT,
	unit_price DECIMAL(10,2),
	subtotal DECIMAL(10,2),
	item_status VARCHAR(30),
    constraint order_id_chk foreign key(order_id) references orders(order_id),
    constraint menu_item_id_chk foreign key(menu_item_id) references menu_items(menu_item_id)
);

-- Basic Analysis/Data Exploration 

-- What is the total number of customers?
select count(*) from customers;

-- What is the total number of restaurants?
select count(*) from restaurants;

-- What are the different cuisine types available?
select distinct cuisine_type from restaurants;

-- How many customers are currently active?
select count(*) from customers where customer_status="active";

-- What are the different payment methods available?
select distinct payment_method from orders;

-- What is the total amount of delivered orders?
select sum(total_amount) from orders where delivery_status="Delivered";

-- What are the different menu item categories available?
select distinct item_category from menu_items;

-- What is the total number of orders?
select count(*) as total_orders from orders;

-- What are the different order statuses available?
select distinct order_status from orders;

-- What is the total discount amount?
select sum(discount_amount) as total_discount from orders;


-- Sprint 4: Objective-Based Analysis

-- 4.1 Understand Customer Profile and Segmentation
		-- Business Objective: The business wants to understand its customer base and identify differences between customer groups.

		-- 1. How are customers distributed across different customer statuses? 
			 select * from customers;
             select customer_status,count(*) as total_customers from customers group by customer_status;
		
        -- 2. Which geographic regions have the highest concentration of customers?
			 select state,city,count(*) as total_customers from customers group by state,city order by total_customers  desc;
             
		-- 3.What payment preferences are observed across the customer base?
			 select preferred_payment_method,count(*) as customer_count from customers group by preferred_payment_method order by customer_count desc;
             
		-- 4.Which customers demonstrate the highest level of engagement with the platform?
			select c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name,count(o.order_id) as total_orders from customers c join
            orders o on c.customer_id=o.customer_id group by customer_name,c.customer_id order by total_orders desc;
            
		-- 5.Which customers contribute the greatest share of revenue?
            select c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name,sum(o.total_amount) as total_spent from customers c join
            orders o on c.customer_id=o.customer_id group by customer_name,c.customer_id order by total_spent desc;
            
-- 4.2 Understand Restaurant and Menu Activity
	-- Business Objective: The business wants to understand how restaurant and menu activity differs across cuisines, locations, and menu categories.
	   -- 1. How are restaurants distributed across different cuisine types?
			 select cuisine_type,count(*) as toatal_restaurants from restaurants group by cuisine_type order by toatal_restaurants desc;
		
	   -- 2. Which locations have the highest restaurant presence?
            select state,city,count(*) as total_restaurants from restaurants group by state,city order by total_restaurants desc;
            
	   -- 3. How do restaurant ratings and price ranges vary across the platform?
            select price_range,count(*) as restaurant_count,round(AVG(rating),2) AS avg_rating
			from restaurants group by price_range;
            
	   -- 4. How is the menu portfolio distributed across categories and vegetarian options?
            select item_category,vegetarian,count(*) as total_items from menu_items group by item_category,vegetarian order by item_category desc;
            
	   -- 5. What proportion of restaurants and menu items are currently active and available? 
             SELECT restaurant_status,COUNT(*) AS total_restaurants FROM restaurants GROUP BY restaurant_status;
             SELECT item_status,COUNT(*) AS total_menu_items FROM menu_items GROUP BY item_status;
             
             
	-- 4.3 Analyze Order Patterns
		-- Business Objective: The business wants to understand how customers place orders and how order activity changes over time.
           -- 1.How are orders distributed across different order statuses?
                select order_status, count(*) as total_orders from orders group by order_status;
                
		   -- 2. Which restaurants and cuisines receive the highest order volume?
                select r.cuisine_type, count(o.order_id) as total_orders from restaurants r join 
                orders o on r.restaurant_id=o.restaurant_id group by r.cuisine_type order by total_orders desc;
                
		   -- 3.How do order values and discounts vary across customer orders?
                select round(avg(total_amount),2) as avg_order_value, round(avg(discount_amount),2) as avg_discount,
                sum(discount_amount) as total_discount from orders;
                
			-- 4.How does order activity change over time? 
                select year(order_date) as year, month(order_date) as month, count(*) as total_orders from orders 
                group by year(order_date), month(order_date) order by year, month;
                
		    -- 5. How does ordering behavior differ across customer groups?
                select c.customer_status, count(o.order_id) as total_orders, round(avg(o.total_amount),2) as avg_order_value from customers c join 
                orders o on c.customer_id=o.customer_id group by c.customer_status;
                
			-- 6.What is the relationship between order quantity, item subtotal, and total order value?
                select o.order_id, sum(oi.quantity) as total_quantity, sum(oi.subtotal) as item_subtotal, o.total_amount from orders o join
                order_items oi on o.order_id=oi.order_id group by o.order_id, o.total_amount;
                
                
	-- 4.4 Evaluate Payment and Delivery Performance
        -- Business Objective: The business wants to understand payment outcomes and whether orders are moving through the delivery process as expected.
			-- 1. How are payments distributed across different payment methods?
                select payment_method, count(*) as total_orders from orders group by payment_method order by total_orders desc;
                
			-- 2.How do payment outcomes vary across the platform?
               select payment_status, count(*) as total_orders from orders group by payment_status;
               
			-- 3. How are orders progressing through the delivery process?
               select delivery_status, count(*) as total_orders from orders group by delivery_status;
               
			-- 4. What proportion of orders are cancelled?
               select order_status, count(*) as total_orders from orders where order_status='Cancelled' group by order_status;
               
			-- 5. How is delivery workload distributed among delivery partners?
               select delivery_partner_name, count(*) as total_deliveries from orders group by delivery_partner_name order by total_deliveries desc;
               
			-- 6. How does order activity vary by date and time?
               select order_date, count(*) as total_orders from orders group by order_date order by order_date;
               
		
	-- 4.5 Understand Menu Item Usage and Product Engagement
	 -- Business Objective: The business wants to understand which menu products drive demand and how menu characteristics relate to ordering behaviour.
	  -- 1. How is demand distributed across different menu item categories?
          select m.item_category, sum(oi.quantity) as total_quantity_sold from menu_items m join 
          order_items oi on m.menu_item_id=oi.menu_item_id group by m.item_category order by total_quantity_sold desc;
          
	  --  2. Which menu items generate the highest sales volume and revenue?
          select m.item_name, sum(oi.quantity) as total_quantity_sold, round(sum(oi.subtotal),2) as total_sales_value from menu_items m join 
          order_items oi on m.menu_item_id=oi.menu_item_id group by m.item_name order by total_sales_value desc;
          
	  -- 3. How does customer demand differ between vegetarian and non-vegetarian menu items?
         select m.vegetarian, sum(oi.quantity) as total_quantity_sold, round(sum(oi.subtotal),2) as total_sales_value from menu_items m join 
         order_items oi on m.menu_item_id=oi.menu_item_id group by m.vegetarian;
         
	  -- 4. How are menu items distributed across active and inactive statuses?
         select item_status, count(*) as total_items from menu_items group by item_status;
         
	  -- 5. How do availability and preparation time vary across menu items?
         select availability, count(*) as total_items, round(avg(preparation_time),2) as avg_preparation_time from menu_items group by availability;
         
	  --  6. Which restaurants offer the highest-demand menu items?
        select r.restaurant_name, m.item_name, sum(oi.quantity) as total_quantity_sold from restaurants r join
        menu_items m on r.restaurant_id=m.restaurant_id join 
        order_items oi on m.menu_item_id=oi.menu_item_id group by r.restaurant_name,m.item_name order by total_quantity_sold desc;
