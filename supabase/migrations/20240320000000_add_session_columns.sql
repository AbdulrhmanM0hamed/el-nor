-- Add session management columns to students table
ALTER TABLE public.students
ADD COLUMN session_key text NULL,
ADD COLUMN last_session timestamp with time zone NULL;

-- Add comment to explain the columns
COMMENT ON COLUMN public.students.session_key IS 'Unique key for the current user session';
COMMENT ON COLUMN public.students.last_session IS 'Timestamp of the last session update';

-- Create an index on session_key for faster lookups
CREATE INDEX idx_students_session_key ON public.students(session_key);

-- Add a function to clear session data
CREATE OR REPLACE FUNCTION clear_session_data(user_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.students
  SET session_key = NULL,
      last_session = NULL
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql; 