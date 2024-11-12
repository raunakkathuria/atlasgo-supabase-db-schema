-- Create products schema
CREATE SCHEMA IF NOT EXISTS demo_product;

-- Product categories table
CREATE TABLE demo_product.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE demo_product.products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES demo_product.categories(id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    sku VARCHAR(50) UNIQUE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Product reviews table
CREATE TABLE demo_product.reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES demo_product.products(id) ON DELETE CASCADE,
    user_id UUID REFERENCES demo_user.users(id) ON DELETE SET NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION demo_product.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers to tables
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON demo_product.categories
    FOR EACH ROW
    EXECUTE FUNCTION demo_product.update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON demo_product.products
    FOR EACH ROW
    EXECUTE FUNCTION demo_product.update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON demo_product.reviews
    FOR EACH ROW
    EXECUTE FUNCTION demo_product.update_updated_at_column();

-- Create indexes for better performance
CREATE INDEX idx_products_category ON demo_product.products(category_id);
CREATE INDEX idx_reviews_product ON demo_product.reviews(product_id);
CREATE INDEX idx_reviews_user ON demo_product.reviews(user_id);
