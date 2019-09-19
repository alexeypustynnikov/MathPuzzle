CREATE or replace TYPE IntArray AS VARRAY(25) OF varchar(500);
/
CREATE OR REPLACE TYPE Stack AS OBJECT (
   max_size INTEGER,
   top      INTEGER,
   position IntArray,
   --MEMBER PROCEDURE initialize,
   constructor function Stack(self in out stack) return self as result,
   MEMBER FUNCTION full RETURN BOOLEAN,
   MEMBER FUNCTION empty RETURN BOOLEAN,
   MEMBER PROCEDURE push (n IN Varchar2),
   MEMBER function pop(self in out stack) return varchar2
)
/
CREATE OR REPLACE TYPE BODY Stack AS

   constructor function Stack(self in out stack) return self as result is
   BEGIN
      self.top := 0;
      -- call constructor for varray and set element 1 to NULL
      self.position := IntArray(NULL);
      self.max_size := position.LIMIT;  -- use size constraint (25)
      self.position.EXTEND(max_size - 1, 1);  -- copy element 1
      return;
   END;

   MEMBER FUNCTION full RETURN BOOLEAN IS
   -- return TRUE if stack is full
   BEGIN
      RETURN (top = max_size);
   END full;

   MEMBER FUNCTION empty RETURN BOOLEAN IS
   -- return TRUE if stack is empty
   BEGIN
      RETURN (top = 0);
   END empty;

   MEMBER PROCEDURE push (n IN VARCHAR2) IS
   -- push integer onto stack
   BEGIN
      IF NOT full THEN
         top := top + 1;
         position(top) := n;
      ELSE  -- stack is full
         RAISE_APPLICATION_ERROR(-20101, 'stack overflow');
      END IF;
   END push;
   
   MEMBER function pop(self in out stack) return varchar2 IS
   -- pop integer off stack and return its value
   n  varchar2(1000);
   BEGIN
      IF NOT empty THEN
         n := position(top);
         self.top := self.top - 1;
      ELSE  -- stack is empty
         RAISE_APPLICATION_ERROR(-20102, 'stack underflow');
      END IF;
   return n;
   END pop;
END;
/
