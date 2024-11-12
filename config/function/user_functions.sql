-- Function to create a new user with profile
CREATE OR REPLACE FUNCTION demo_user.create_user_with_profile(
    p_email VARCHAR(255),
    p_username VARCHAR(50),
    p_password_hash VARCHAR(255),
    p_full_name VARCHAR(100),
    p_bio TEXT DEFAULT NULL,
    p_location VARCHAR(100) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Insert user
    INSERT INTO demo_user.users (email, username, password_hash, full_name)
    VALUES (p_email, p_username, p_password_hash, p_full_name)
    RETURNING id INTO v_user_id;

    -- Create profile
    INSERT INTO demo_user.profiles (user_id, bio, location)
    VALUES (v_user_id, p_bio, p_location);

    RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create a new session
CREATE OR REPLACE FUNCTION demo_user.create_session(
    p_user_id UUID,
    p_token VARCHAR(255),
    p_expires_in INTERVAL DEFAULT INTERVAL '24 hours'
) RETURNS UUID AS $$
DECLARE
    v_session_id UUID;
BEGIN
    INSERT INTO demo_user.sessions (user_id, token, expires_at)
    VALUES (p_user_id, p_token, CURRENT_TIMESTAMP + p_expires_in)
    RETURNING id INTO v_session_id;

    RETURN v_session_id;
END;
$$ LANGUAGE plpgsql;

-- Function to validate session
CREATE OR REPLACE FUNCTION demo_user.validate_session(
    p_token VARCHAR(255)
) RETURNS TABLE (
    is_valid BOOLEAN,
    user_id UUID,
    username VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN s.expires_at > CURRENT_TIMESTAMP THEN true
            ELSE false
        END as is_valid,
        u.id as user_id,
        u.username
    FROM demo_user.sessions s
    JOIN demo_user.users u ON u.id = s.user_id
    WHERE s.token = p_token
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get user profile with basic info
CREATE OR REPLACE FUNCTION demo_user.get_user_profile(
    p_user_id UUID
) RETURNS TABLE (
    user_id UUID,
    email VARCHAR(255),
    username VARCHAR(50),
    full_name VARCHAR(100),
    bio TEXT,
    location VARCHAR(100),
    avatar_url VARCHAR(255),
    website VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.email,
        u.username,
        u.full_name,
        p.bio,
        p.location,
        p.avatar_url,
        p.website,
        u.created_at
    FROM demo_user.users u
    LEFT JOIN demo_user.profiles p ON p.user_id = u.id
    WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;
