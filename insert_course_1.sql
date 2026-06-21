-- =====================================================================
-- Mathify data migration: MIT OCW RES.18-010 "A Vision of Linear Algebra"
-- Targets the EXISTING mathify_schema.sql (courses/chapters/learning_modules/
-- quizzes/questions/multiple_choice_options/fill_blank_questions/fill_blank_answers)
--
-- Mapping decisions (read before running):
--   1. question_type ENUM only supports MULTIPLE_CHOICE/FILL_BLANK/DRAG_AND_DROP.
--      -> beginner tier  => MULTIPLE_CHOICE (native fit)
--      -> intermediate/advanced tiers (numeric) => FILL_BLANK
--         (numeric answer stored as exact-match text in fill_blank_answers)
--   2. No difficulty/tier column exists on quizzes -> tier is encoded in the
--      quiz title, e.g. "Eigenvalues and Eigenvectors -- Beginner Quiz"
--   3. learning_modules.duration_secs is NOT NULL for VIDEO type by your CHECK
--      constraint. Real runtimes are NOT verified for these YouTube videos
--      (only "Five Factorizations of a Matrix" is documented by MIT itself as
--      "~1 hour"). ALL OTHER durations below are PLACEHOLDERS (600s = 10:00).
--      See the TODO list at the bottom of this file -- update before relying
--      on duration-based UI (progress bar, time remaining, etc).
--   4. courses table has no license/attribution column, so the required
--      CC BY-NC-SA attribution text is appended to `description` as a stopgap.
-- =====================================================================

USE mathify_db;
SET FOREIGN_KEY_CHECKS = 0;


-- ---------------------------------------------------------------
-- courses
-- ---------------------------------------------------------------

INSERT INTO courses (course_id, title, description, category) VALUES
('4c528cbb-52bc-4ef2-8448-f43233d1770a', 'A Vision of Linear Algebra', 'A Vision of Linear Algebra -- College/undergraduate-level Linear Algebra, typically taken after Calculus (year 1-2 of a STEM degree). Fits as CORE content for an undergraduate-focused app. [Source: MIT OpenCourseWare, RES.18-010 A Vision of Linear Algebra, Prof. Gilbert Strang. Spring 2020. License: CC BY-NC-SA. https://ocw.mit.edu]', 'Linear Algebra');


-- ---------------------------------------------------------------
-- chapters
-- ---------------------------------------------------------------
INSERT INTO chapters (chapter_id, course_id, title, description, xp_reward, order_index) VALUES
('9c800e26-6a1b-4186-826a-debbf1653932', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Intro: A New Way to Start Linear Algebra', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 1),
('f4efd563-0da0-43d3-9c67-3487424b6e68', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Part 1: The Column Space of a Matrix', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 2),
('c2abf00d-9cf7-4ba1-9074-89aef403efe5', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Part 2: The Big Picture of Linear Algebra', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 3),
('6f3c2ff1-0882-489e-8704-617c05e99c24', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Part 3: Orthogonal Vectors', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 4),
('5a314378-b4e3-4d54-9ec2-e574fafc2bcf', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Part 4: Eigenvalues and Eigenvectors', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 5),
('f65b7ac5-7c53-46ab-94e2-e414f2bca420', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Part 5: Singular Values and Singular Vectors', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 6),
('c0becb43-8e98-4e0c-98fd-a8c9bdc23d62', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Part 6: Finding the Nullspace: Solving Ax = 0 by Elimination', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 7),
('69027658-bcb0-4f58-9f0e-fa8e2616d07d', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Five Factorizations of a Matrix', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 8),
('099dac0a-9bbb-4d68-b7a1-4257ae4d2469', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'The Four Fundamental Subspaces and Least Squares', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 9),
('5c3facd2-7095-477f-ad0b-954fd768f274', '4c528cbb-52bc-4ef2-8448-f43233d1770a', 'Elimination and Factorization A = CR', 'Source: MIT OpenCourseWare RES.18-010 (CC BY-NC-SA)', 100, 10);


-- ---------------------------------------------------------------
-- learning_modules (VIDEO)
-- ---------------------------------------------------------------
INSERT INTO learning_modules (module_id, chapter_id, title, order_index, module_type, content_url, duration_secs, slide_count) VALUES
('14556ba6-5cf1-4208-b4cd-9c8c671c455a', '9c800e26-6a1b-4186-826a-debbf1653932', 'Intro: A New Way to Start Linear Algebra', 0, 'VIDEO', 'https://www.youtube.com/embed/YrHlHbtiSM0', 600, NULL),
('a04679a2-2e90-4e60-a2af-42fbf940c2e5', 'f4efd563-0da0-43d3-9c67-3487424b6e68', 'Part 1: The Column Space of a Matrix', 0, 'VIDEO', 'https://www.youtube.com/embed/azzrfdysfI0', 600, NULL),
('3e6e6d9a-abbf-4fe9-95f4-28f8f13a8a7a', 'c2abf00d-9cf7-4ba1-9074-89aef403efe5', 'Part 2: The Big Picture of Linear Algebra', 0, 'VIDEO', 'https://www.youtube.com/embed/rwLOfdfc4dw', 600, NULL),
('86c23107-ebb3-494e-a0da-773edf42ce5b', '6f3c2ff1-0882-489e-8704-617c05e99c24', 'Part 3: Orthogonal Vectors', 0, 'VIDEO', 'https://www.youtube.com/embed/j8hEnyOiwhw', 600, NULL),
('1ccfe579-5573-4e83-b398-3bc5b66c0009', '5a314378-b4e3-4d54-9ec2-e574fafc2bcf', 'Part 4: Eigenvalues and Eigenvectors', 0, 'VIDEO', 'https://www.youtube.com/embed/GyC3gl6weYo', 600, NULL),
('f34699ff-009b-40ee-858e-82564cb213f9', 'f65b7ac5-7c53-46ab-94e2-e414f2bca420', 'Part 5: Singular Values and Singular Vectors', 0, 'VIDEO', 'https://www.youtube.com/embed/IHO7_n7Y09s', 600, NULL),
('c593eab8-c41d-45da-9367-28e55c326fe7', 'c0becb43-8e98-4e0c-98fd-a8c9bdc23d62', 'Part 6: Finding the Nullspace: Solving Ax = 0 by Elimination', 0, 'VIDEO', 'https://www.youtube.com/embed/JFIaRtKNP2E', 600, NULL),
('b28a7c2e-586c-4728-a7f4-b73300f49510', '69027658-bcb0-4f58-9f0e-fa8e2616d07d', 'Five Factorizations of a Matrix', 0, 'VIDEO', 'https://www.youtube.com/embed/nTwRjQ4xqUc', 3600, NULL),
('a0d579f2-be6e-49ea-ba27-eeec3f8a44c8', '099dac0a-9bbb-4d68-b7a1-4257ae4d2469', 'The Four Fundamental Subspaces and Least Squares', 0, 'VIDEO', 'https://www.youtube.com/embed/jY-Mu6XQ3NU', 600, NULL),
('56a30a1a-3306-4c0f-895f-ac504eff2cd2', '5c3facd2-7095-477f-ad0b-954fd768f274', 'Elimination and Factorization A = CR', 0, 'VIDEO', 'https://www.youtube.com/embed/PrErxYzSANo', 600, NULL);


-- ---------------------------------------------------------------
-- quizzes
-- ---------------------------------------------------------------
INSERT INTO quizzes (quiz_id, chapter_id, title, passing_score) VALUES
('e7407aec-a0d3-43ab-95d9-19e4d6c67086', '9c800e26-6a1b-4186-826a-debbf1653932', 'Intro: A New Way to Start Linear Algebra -- Beginner Quiz', 60),
('230416d9-30fe-4a0d-b0ab-37633d8f79fa', '9c800e26-6a1b-4186-826a-debbf1653932', 'Intro: A New Way to Start Linear Algebra -- Intermediate Quiz', 70),
('bde51fd5-0b16-47c8-b27e-ac5295346b46', '9c800e26-6a1b-4186-826a-debbf1653932', 'Intro: A New Way to Start Linear Algebra -- Advanced Quiz', 80),
('8781d41d-52c0-471c-92ee-71ba81a14fb6', 'f4efd563-0da0-43d3-9c67-3487424b6e68', 'Part 1: The Column Space of a Matrix -- Beginner Quiz', 60),
('7dc036eb-77bd-48fb-a898-ec07f8fe5c46', 'f4efd563-0da0-43d3-9c67-3487424b6e68', 'Part 1: The Column Space of a Matrix -- Intermediate Quiz', 70),
('9b9ab3f1-9dcd-418e-ad10-f8cf158c1985', 'f4efd563-0da0-43d3-9c67-3487424b6e68', 'Part 1: The Column Space of a Matrix -- Advanced Quiz', 80),
('89ae88d1-de86-4f6a-8d95-7677a200f509', 'c2abf00d-9cf7-4ba1-9074-89aef403efe5', 'Part 2: The Big Picture of Linear Algebra -- Beginner Quiz', 60),
('4ba54bc2-26c9-4302-8f59-181e4e813ae7', 'c2abf00d-9cf7-4ba1-9074-89aef403efe5', 'Part 2: The Big Picture of Linear Algebra -- Intermediate Quiz', 70),
('70c6e769-31ab-4257-892c-80251755739a', 'c2abf00d-9cf7-4ba1-9074-89aef403efe5', 'Part 2: The Big Picture of Linear Algebra -- Advanced Quiz', 80),
('e5669c44-ec48-4865-9b6a-89a8ca0f148d', '6f3c2ff1-0882-489e-8704-617c05e99c24', 'Part 3: Orthogonal Vectors -- Beginner Quiz', 60),
('f73ec23c-7993-4af9-b1b1-5fc45306d8a4', '6f3c2ff1-0882-489e-8704-617c05e99c24', 'Part 3: Orthogonal Vectors -- Intermediate Quiz', 70),
('a7000cb2-f220-49f7-9f5e-1b5bdfee3934', '6f3c2ff1-0882-489e-8704-617c05e99c24', 'Part 3: Orthogonal Vectors -- Advanced Quiz', 80),
('f6af9d58-261b-4dcc-8636-0e590561afd4', '5a314378-b4e3-4d54-9ec2-e574fafc2bcf', 'Part 4: Eigenvalues and Eigenvectors -- Beginner Quiz', 60),
('784ee29f-fc13-42cc-8426-e2a738abb1f3', '5a314378-b4e3-4d54-9ec2-e574fafc2bcf', 'Part 4: Eigenvalues and Eigenvectors -- Intermediate Quiz', 70),
('e85cb073-6ff9-4d3f-b99c-1b151cec33e1', '5a314378-b4e3-4d54-9ec2-e574fafc2bcf', 'Part 4: Eigenvalues and Eigenvectors -- Advanced Quiz', 80),
('72c47167-142f-4303-b648-68d2dc4a1c18', 'f65b7ac5-7c53-46ab-94e2-e414f2bca420', 'Part 5: Singular Values and Singular Vectors -- Beginner Quiz', 60),
('d8ac5483-1dbc-42b9-a6c8-04a6df1bf40a', 'f65b7ac5-7c53-46ab-94e2-e414f2bca420', 'Part 5: Singular Values and Singular Vectors -- Intermediate Quiz', 70),
('dbac8b79-b634-4a90-bfc0-5a009754a89d', 'f65b7ac5-7c53-46ab-94e2-e414f2bca420', 'Part 5: Singular Values and Singular Vectors -- Advanced Quiz', 80),
('4f9b3a73-694a-4e3e-bad5-c1e6dc7e58dd', 'c0becb43-8e98-4e0c-98fd-a8c9bdc23d62', 'Part 6: Finding the Nullspace: Solving Ax = 0 by Elimination -- Beginner Quiz', 60),
('73f0637e-2679-4c8a-ad46-d4d631b820a9', 'c0becb43-8e98-4e0c-98fd-a8c9bdc23d62', 'Part 6: Finding the Nullspace: Solving Ax = 0 by Elimination -- Intermediate Quiz', 70),
('7f7b77a2-bff5-47ff-be68-87b9c35ccb25', 'c0becb43-8e98-4e0c-98fd-a8c9bdc23d62', 'Part 6: Finding the Nullspace: Solving Ax = 0 by Elimination -- Advanced Quiz', 80),
('d4b36c39-bee5-4e2a-994e-9d50ee6bbe05', '69027658-bcb0-4f58-9f0e-fa8e2616d07d', 'Five Factorizations of a Matrix -- Beginner Quiz', 60),
('cd8541f2-59c6-46d6-9397-39fb4b8555d1', '69027658-bcb0-4f58-9f0e-fa8e2616d07d', 'Five Factorizations of a Matrix -- Intermediate Quiz', 70),
('13e4cb7a-4178-4aa0-bd0d-a092db8ce3a5', '69027658-bcb0-4f58-9f0e-fa8e2616d07d', 'Five Factorizations of a Matrix -- Advanced Quiz', 80),
('ef5eeb33-d976-48a7-85a5-0cd3d387c9e1', '099dac0a-9bbb-4d68-b7a1-4257ae4d2469', 'The Four Fundamental Subspaces and Least Squares -- Beginner Quiz', 60),
('e7d4a08d-6ad0-4a99-89b0-bc854ff6420f', '099dac0a-9bbb-4d68-b7a1-4257ae4d2469', 'The Four Fundamental Subspaces and Least Squares -- Intermediate Quiz', 70),
('728a4c21-f23e-4cb2-beef-a82269bbd8e6', '099dac0a-9bbb-4d68-b7a1-4257ae4d2469', 'The Four Fundamental Subspaces and Least Squares -- Advanced Quiz', 80),
('547f01d1-390d-495a-9d19-56813c4b9e35', '5c3facd2-7095-477f-ad0b-954fd768f274', 'Elimination and Factorization A = CR -- Beginner Quiz', 60),
('56ef4237-2e9e-432d-a4ad-315134e1e09f', '5c3facd2-7095-477f-ad0b-954fd768f274', 'Elimination and Factorization A = CR -- Intermediate Quiz', 70),
('c73e7892-3584-4f82-bc6b-ce71bee95e79', '5c3facd2-7095-477f-ad0b-954fd768f274', 'Elimination and Factorization A = CR -- Advanced Quiz', 80);


-- ---------------------------------------------------------------
-- questions
-- ---------------------------------------------------------------
INSERT INTO questions (question_id, quiz_id, prompt, points, question_type, order_index) VALUES
('710219db-1a6b-4d2e-a23f-07b66c707a4b', 'e7407aec-a0d3-43ab-95d9-19e4d6c67086', 'In the traditional approach to teaching linear algebra, what topic usually comes first?', 1, 'MULTIPLE_CHOICE', 0),
('26bf6476-5cf1-4e65-918b-3494db454bb0', 'e7407aec-a0d3-43ab-95d9-19e4d6c67086', 'A core idea in linear algebra is thinking of matrix multiplication Ax as:', 1, 'MULTIPLE_CHOICE', 1),
('28911e72-62a6-4426-a841-08401d8e42f7', 'e7407aec-a0d3-43ab-95d9-19e4d6c67086', 'Why might starting with column space / vector pictures (instead of pure elimination) help build intuition?', 1, 'MULTIPLE_CHOICE', 2),
('97973975-0bb7-4494-998f-aca25352b856', '230416d9-30fe-4a0d-b0ab-37633d8f79fa', 'Let u = (2, -1, 3) and w = (1, 4, -2). Compute the dot product u . w.', 1, 'FILL_BLANK', 0),
('c7e1c7f3-1e7f-4135-b1f2-ee0d30006318', '230416d9-30fe-4a0d-b0ab-37633d8f79fa', 'Let A = [[1, 2], [3, 4]] and x = (1, 1). What is the FIRST entry of Ax?', 1, 'FILL_BLANK', 1),
('b9821f5a-758b-48b0-b7d7-5168a2248332', 'bde51fd5-0b16-47c8-b27e-ac5295346b46', 'v1=(1,2,-1), v2=(0,3,2), v3=(2,-1,1). Compute w = 2v1 - v2 + 3v3. What is the FIRST component of w?', 1, 'FILL_BLANK', 0),
('12016df1-07bc-444d-8cbf-8b751ba9a647', 'bde51fd5-0b16-47c8-b27e-ac5295346b46', 'Using the same w = 2v1 - v2 + 3v3, what is the SECOND component of w?', 1, 'FILL_BLANK', 1),
('eedf8eb6-0f88-42da-9c82-8ec25032b04a', '8781d41d-52c0-471c-92ee-71ba81a14fb6', 'The column space of a matrix A is best described as:', 1, 'MULTIPLE_CHOICE', 0),
('46c7fd00-eb11-4e71-a821-43a1f84ee705', '8781d41d-52c0-471c-92ee-71ba81a14fb6', 'If A is a 5x3 matrix, which space could its column space live in?', 1, 'MULTIPLE_CHOICE', 1),
('ff25ffac-412e-4595-8a60-ff6e7cc7a100', '8781d41d-52c0-471c-92ee-71ba81a14fb6', 'Why is the column space useful when solving Ax = b?', 1, 'MULTIPLE_CHOICE', 2),
('2b7efcbb-66ab-43cc-abe2-541993a7262c', '7dc036eb-77bd-48fb-a898-ec07f8fe5c46', 'What is the rank (dimension of the column space) of A = [[1, 2], [2, 4]]?', 1, 'FILL_BLANK', 0),
('1e8c39b1-7fb8-405f-9d87-5c4972f6007a', '7dc036eb-77bd-48fb-a898-ec07f8fe5c46', 'What is the rank of A = [[1, 0], [0, 1], [1, 1]]?', 1, 'FILL_BLANK', 1),
('bc6c67fa-f1fb-46b3-95f6-8038db2eaab3', '9b9ab3f1-9dcd-418e-ad10-f8cf158c1985', 'A = [[1,2,3],[2,4,6],[0,1,1]]. What is the rank (dimension of column space)?', 1, 'FILL_BLANK', 0),
('c64701c3-7ae2-4f01-a2ca-cd5ad3b103eb', '9b9ab3f1-9dcd-418e-ad10-f8cf158c1985', 'For the same A, what is the dimension of its null space (3 columns total)?', 1, 'FILL_BLANK', 1),
('1ad9af57-b27b-4888-b93f-a6fba402867a', '89ae88d1-de86-4f6a-8d95-7677a200f509', 'The ''Four Fundamental Subspaces'' associated with a matrix A typically include the column space, the row space, and which two others?', 1, 'MULTIPLE_CHOICE', 0),
('d487065f-cce8-4ec6-b5c8-c068091b3b7c', '89ae88d1-de86-4f6a-8d95-7677a200f509', 'For an m x n matrix A, the row space and the null space of A both live in:', 1, 'MULTIPLE_CHOICE', 1),
('6d72c47e-ae1b-4f1c-8af2-88f536b73f10', '89ae88d1-de86-4f6a-8d95-7677a200f509', 'In the ''big picture'' view, the row space and null space of A are related by being:', 1, 'MULTIPLE_CHOICE', 2),
('23c025f6-6f7e-4ee4-b10c-c812d929c448', '4ba54bc2-26c9-4302-8f59-181e4e813ae7', 'A is a 4x6 matrix with rank 3. By the rank-nullity theorem, what is the dimension of its null space?', 1, 'FILL_BLANK', 0),
('3531019d-51f9-452f-aace-aae5d37efb15', '4ba54bc2-26c9-4302-8f59-181e4e813ae7', 'A is a 5x3 matrix with rank 3 (full column rank). What is the dimension of the LEFT null space (null space of A^T)?', 1, 'FILL_BLANK', 1),
('d13aa71a-b093-4e96-bbc5-5d612ef7a693', '70c6e769-31ab-4257-892c-80251755739a', 'A = [[1,2,3],[4,5,6],[7,8,9]]. What is the rank of A?', 1, 'FILL_BLANK', 0),
('6d96373f-8676-4d92-b906-2ff312d7f34f', '70c6e769-31ab-4257-892c-80251755739a', 'For the same A, what is the dimension of its null space?', 1, 'FILL_BLANK', 1),
('dd139d1f-3454-40ed-89b8-d4f08bdee0f2', 'e5669c44-ec48-4865-9b6a-89a8ca0f148d', 'Two vectors u and v are orthogonal when:', 1, 'MULTIPLE_CHOICE', 0),
('aafdb775-7f76-4168-80b8-d2699dd6d513', 'e5669c44-ec48-4865-9b6a-89a8ca0f148d', 'A set of mutually orthogonal vectors, each of length 1, is called:', 1, 'MULTIPLE_CHOICE', 1),
('c3355d3f-6048-48d4-ac68-497420c7f461', 'e5669c44-ec48-4865-9b6a-89a8ca0f148d', 'Why are orthogonal/orthonormal bases especially convenient in linear algebra?', 1, 'MULTIPLE_CHOICE', 2),
('8f0b2387-ab08-4624-b1d5-77f598c536a1', 'f73ec23c-7993-4af9-b1b1-5fc45306d8a4', 'Compute the dot product of v1 = (1, 2, 3) and v2 = (3, 0, -1). (A result of 0 means they''re orthogonal.)', 1, 'FILL_BLANK', 0),
('aa597010-bb09-4df4-b188-d37fdaa0a009', 'f73ec23c-7993-4af9-b1b1-5fc45306d8a4', 'What is the length (norm) of the vector (3, 4)?', 1, 'FILL_BLANK', 1),
('2ea2936f-8c72-4dd1-ad84-25a378ba273d', 'a7000cb2-f220-49f7-9f5e-1b5bdfee3934', 'a=(1,1,0), b=(2,0,1). What is the projection coefficient (a.b)/(a.a) used to remove a''s direction from b (the first step of Gram-Schmidt)?', 1, 'FILL_BLANK', 0),
('beb8e66f-e2d8-4a30-a5a1-34345e0b1e6e', 'a7000cb2-f220-49f7-9f5e-1b5bdfee3934', 'Using that projection coefficient, the orthogonal component is b_orth = b - coeff*a. What is the SECOND entry of b_orth?', 1, 'FILL_BLANK', 1),
('94782da8-ffb4-45ae-8fde-049518c47dfe', 'f6af9d58-261b-4dcc-8636-0e590561afd4', 'An eigenvector of a matrix A is a non-zero vector v such that:', 1, 'MULTIPLE_CHOICE', 0),
('a88e3f68-8593-49ed-81a6-1e5f00b9c28c', 'f6af9d58-261b-4dcc-8636-0e590561afd4', 'The scalar λ in Av = λv is called:', 1, 'MULTIPLE_CHOICE', 1),
('e47346ce-e999-4908-9356-f2ed56108515', 'f6af9d58-261b-4dcc-8636-0e590561afd4', 'Geometrically, multiplying an eigenvector by its matrix A results in a vector that is:', 1, 'MULTIPLE_CHOICE', 2),
('9c3660dc-4398-41b9-ab50-8abdea255757', '784ee29f-fc13-42cc-8426-e2a738abb1f3', 'Matrix A = [[4, 1], [2, 3]]. What is the LARGER of its two eigenvalues?', 1, 'FILL_BLANK', 0),
('d5bd5ad6-3997-439f-aaca-16f7f08d995e', '784ee29f-fc13-42cc-8426-e2a738abb1f3', 'What is the SMALLER eigenvalue of the same matrix A = [[4, 1], [2, 3]]?', 1, 'FILL_BLANK', 1),
('f8b7241c-ef5b-4118-8687-87fbb49077de', 'e85cb073-6ff9-4d3f-b99c-1b151cec33e1', 'A = [[2,1,1],[1,2,1],[1,1,2]]. What is the LARGEST eigenvalue?', 1, 'FILL_BLANK', 0),
('ffe90d6f-7a74-4603-a3c6-4c514476d59c', 'e85cb073-6ff9-4d3f-b99c-1b151cec33e1', 'What is the sum of ALL THREE eigenvalues of the same A? (Hint: this equals the trace.)', 1, 'FILL_BLANK', 1),
('16c8423e-93d9-46a8-b229-4559fbe0f155', '72c47167-142f-4303-b648-68d2dc4a1c18', 'Singular Value Decomposition (SVD) factors a matrix A into:', 1, 'MULTIPLE_CHOICE', 0),
('4397e4ab-edbb-4c56-91a7-ed07faf559b5', '72c47167-142f-4303-b648-68d2dc4a1c18', 'Unlike eigenvalues, singular values exist for:', 1, 'MULTIPLE_CHOICE', 1),
('5503d1c5-57d9-4d26-a6c4-400419d70ea6', '72c47167-142f-4303-b648-68d2dc4a1c18', 'In A = UΣV^T, the singular values (entries of Σ) are always:', 1, 'MULTIPLE_CHOICE', 2),
('d9f37f0b-77a7-4d44-9289-5ed608acdfcb', 'd8ac5483-1dbc-42b9-a6c8-04a6df1bf40a', 'Matrix A = [[3, 0], [0, 4]]. What is its LARGEST singular value?', 1, 'FILL_BLANK', 0),
('d1ac1f91-4b31-4506-900b-7a9a4a798392', 'd8ac5483-1dbc-42b9-a6c8-04a6df1bf40a', 'What is the SMALLEST singular value of the same A = [[3, 0], [0, 4]]?', 1, 'FILL_BLANK', 1),
('efbe9d99-8aa3-400b-8467-7cd03cd54ad5', 'dbac8b79-b634-4a90-bfc0-5a009754a89d', 'A = [[2,0,0],[0,3,0],[0,0,6]]. What is the LARGEST singular value?', 1, 'FILL_BLANK', 0),
('fcda0436-e980-40cd-80ca-b832b17aa748', 'dbac8b79-b634-4a90-bfc0-5a009754a89d', 'What is the SUM OF SQUARES of all three singular values of the same A? (Hint: this equals trace(A^T A).)', 1, 'FILL_BLANK', 1),
('3ccd33aa-db31-4cf5-b74b-a46444d12ff2', '4f9b3a73-694a-4e3e-bad5-c1e6dc7e58dd', 'The null space of a matrix A is the set of all vectors x such that:', 1, 'MULTIPLE_CHOICE', 0),
('12eadade-56bd-46a2-8385-7e524a785ca9', '4f9b3a73-694a-4e3e-bad5-c1e6dc7e58dd', 'When using elimination to find the null space, the ''free variables'' correspond to:', 1, 'MULTIPLE_CHOICE', 1),
('a65e6b7c-f1c8-41d7-9770-9895d796e01e', '4f9b3a73-694a-4e3e-bad5-c1e6dc7e58dd', 'If A is an n x n invertible matrix, what is its null space?', 1, 'MULTIPLE_CHOICE', 2),
('8bb18816-509b-427b-ab48-1913be1205fc', '73f0637e-2679-4c8a-ad46-d4d631b820a9', 'A = [[1, 2], [2, 4]]. What is the dimension of its null space?', 1, 'FILL_BLANK', 0),
('cf20f358-81d4-4e74-aa06-555fa8d3e7d2', '73f0637e-2679-4c8a-ad46-d4d631b820a9', 'For A = [[1, 2], [2, 4]], a null-space vector has x1 = 2. What must x2 be so that Ax = 0?', 1, 'FILL_BLANK', 1),
('7e03c66b-46ac-4be9-94ec-e22a4e9114c7', '7f7b77a2-bff5-47ff-be68-87b9c35ccb25', 'A = [[1,2,3],[2,4,6],[1,1,1]]. What is the dimension of the null space?', 1, 'FILL_BLANK', 0),
('3edf32f0-beae-4f37-b4ef-0f4406ff87cb', '7f7b77a2-bff5-47ff-be68-87b9c35ccb25', 'A null space vector of the same A has x1 = 1. What must x2 be (so that Ax = 0)?', 1, 'FILL_BLANK', 1),
('2aca480b-640a-4f47-83f7-4c655721c311', 'd4b36c39-bee5-4e2a-994e-9d50ee6bbe05', 'The factorization A = LU is most directly the result of which process?', 1, 'MULTIPLE_CHOICE', 0),
('049d6b85-0afd-426a-89f9-c6964ba087bc', 'd4b36c39-bee5-4e2a-994e-9d50ee6bbe05', 'Which factorization is specifically built from orthonormal eigenvectors and is only available for symmetric matrices?', 1, 'MULTIPLE_CHOICE', 1),
('3f46c2eb-38b9-46b3-ba3e-c67d9262b7a8', 'd4b36c39-bee5-4e2a-994e-9d50ee6bbe05', 'Why might a textbook present several different factorizations of the same matrix A (LU, QR, eigendecomposition, SVD, etc.) instead of just one?', 1, 'MULTIPLE_CHOICE', 2),
('41ada8ab-4ce1-4f7f-9183-1b57eb2804cb', 'cd8541f2-59c6-46d6-9397-39fb4b8555d1', 'A = [[2, 1], [4, 3]]. In the LU factorization, what multiplier l21 is used to eliminate the entry below the first pivot (i.e., a21 / a11)?', 1, 'FILL_BLANK', 0),
('c01a09e2-3263-4e64-b046-d7b38a2c1b9f', 'cd8541f2-59c6-46d6-9397-39fb4b8555d1', 'What is det(A) for A = [[2, 1], [4, 3]]?', 1, 'FILL_BLANK', 1),
('cea1f259-9b42-48b9-a398-321ee65a06fc', '13e4cb7a-4178-4aa0-bd0d-a092db8ce3a5', 'A = [[1,1,1],[2,3,5],[4,6,8]]. Using elimination in natural row order (no row swaps), what multiplier l31 (= a31/a11) is used to clear the entry below the first pivot in row 3?', 1, 'FILL_BLANK', 0),
('aa4875ff-eaae-4c1d-a110-1eb40e3d06d6', '13e4cb7a-4178-4aa0-bd0d-a092db8ce3a5', 'What is det(A) for the same A, computed as the product of the three pivots from elimination?', 1, 'FILL_BLANK', 1),
('33168d7a-a4bc-4b4c-ba10-6033f363328c', 'ef5eeb33-d976-48a7-85a5-0cd3d387c9e1', 'Least squares is typically used when a system Ax = b:', 1, 'MULTIPLE_CHOICE', 0),
('7faa6823-b8b5-4be6-8edd-5bd767efb522', 'ef5eeb33-d976-48a7-85a5-0cd3d387c9e1', 'The least-squares solution to Ax = b can be found by solving which equation?', 1, 'MULTIPLE_CHOICE', 1),
('25329521-119b-4351-844f-e8514eccf403', 'ef5eeb33-d976-48a7-85a5-0cd3d387c9e1', 'Geometrically, the least-squares solution finds the point in the column space of A that is:', 1, 'MULTIPLE_CHOICE', 2),
('b5c867d8-0266-4377-a2e9-641852f41c4b', 'e7d4a08d-6ad0-4a99-89b0-bc854ff6420f', 'You want the single constant c that best fits (least squares) the data b = (1, 3, 5). What is the best c?', 1, 'FILL_BLANK', 0),
('35c9baa1-b8fa-4b2f-ba58-45ef1a1ec7d4', 'e7d4a08d-6ad0-4a99-89b0-bc854ff6420f', 'Using that best-fit c, what is the sum of the squared residuals (errors)?', 1, 'FILL_BLANK', 1),
('3d6c2824-b5cd-4d5e-a586-55cfa9e6cfc0', '728a4c21-f23e-4cb2-beef-a82269bbd8e6', 'Fit a line y = mx + c (least squares) through the points (0,1), (1,2), (2,6). What is the slope m?', 1, 'FILL_BLANK', 0),
('8f4ccdaa-198c-4d90-b43e-e9ede067944f', '728a4c21-f23e-4cb2-beef-a82269bbd8e6', 'Using that same best-fit line, what is the sum of the squared residuals?', 1, 'FILL_BLANK', 1),
('eda889ec-74a0-46bd-a01b-bf1d36c93e0f', '547f01d1-390d-495a-9d19-56813c4b9e35', 'In the factorization A = CR, the matrix C typically contains:', 1, 'MULTIPLE_CHOICE', 0),
('9ab59c88-94ad-4245-ab88-4e238b7773cd', '547f01d1-390d-495a-9d19-56813c4b9e35', 'The ''R'' in A = CR is connected to which classical process?', 1, 'MULTIPLE_CHOICE', 1),
('81d92439-0a28-4c59-a631-c2eaf76c060b', '547f01d1-390d-495a-9d19-56813c4b9e35', 'One practical benefit of the A = CR factorization is that it directly reveals:', 1, 'MULTIPLE_CHOICE', 2),
('ea2d61e3-7d6e-4152-bccc-304c908dea6d', '56ef4237-2e9e-432d-a4ad-315134e1e09f', 'A = [[1, 2, 3], [2, 4, 6]]. What is the rank of A? (Hint: row 2 is a multiple of row 1.)', 1, 'FILL_BLANK', 0),
('7c32679d-7b78-492d-a1fe-3f15efd36316', 'c73e7892-3584-4f82-bc6b-ce71bee95e79', 'A = [[1,2,1],[2,4,2],[1,2,1]]. What is the rank of A?', 1, 'FILL_BLANK', 0),
('a0ed510c-c0f3-44a0-b715-4dade7a09138', 'c73e7892-3584-4f82-bc6b-ce71bee95e79', 'What is the dimension of the null space of the same A (3 columns total)?', 1, 'FILL_BLANK', 1);


-- ---------------------------------------------------------------
-- multiple_choice_options
-- ---------------------------------------------------------------
INSERT INTO multiple_choice_options (option_id, question_id, option_text, is_correct, order_index) VALUES
('194a1fc4-6663-456d-8388-92b93f3a36a2', '710219db-1a6b-4d2e-a23f-07b66c707a4b', 'Eigenvalues', FALSE, 0),
('0d475131-7a59-41d8-b2dc-438bb1a02601', '710219db-1a6b-4d2e-a23f-07b66c707a4b', 'Solving systems of equations by elimination', TRUE, 1),
('f6434358-5dbb-4dc2-9ab4-68d72cc0dd27', '710219db-1a6b-4d2e-a23f-07b66c707a4b', 'Singular value decomposition', FALSE, 2),
('782bf16f-4b40-4462-861f-4248d333f7f4', '710219db-1a6b-4d2e-a23f-07b66c707a4b', 'Vector spaces in the abstract', FALSE, 3),
('7bd9e32d-740a-4db2-8fdb-3591fd76d291', '26bf6476-5cf1-4e65-918b-3494db454bb0', 'A combination of the columns of A, weighted by the entries of x', TRUE, 0),
('c4caf639-de45-4c68-92be-4e2595fd0fe0', '26bf6476-5cf1-4e65-918b-3494db454bb0', 'Multiplying every entry of A by every entry of x separately with no structure', FALSE, 1),
('3b4bb557-c348-4b23-ab14-61be3099ac0f', '26bf6476-5cf1-4e65-918b-3494db454bb0', 'Only valid when A is a square matrix', FALSE, 2),
('0bcd3f09-7e34-4c2f-9c0e-bcd1d72ccceb', '26bf6476-5cf1-4e65-918b-3494db454bb0', 'The same operation as computing a determinant', FALSE, 3),
('7ecaf21b-021d-4476-beff-5873ec25e200', '28911e72-62a6-4426-a841-08401d8e42f7', 'It removes the need to ever solve equations', FALSE, 0),
('f532a6e8-5dac-42fd-a367-b3ae17e8ed2c', '28911e72-62a6-4426-a841-08401d8e42f7', 'It connects the algebra to a geometric picture of vectors and spaces from the start', TRUE, 1),
('b4fae203-5eae-40c9-9e01-825de79d835a', '28911e72-62a6-4426-a841-08401d8e42f7', 'It only works for 2x2 matrices', FALSE, 2),
('7da59b74-36fd-489f-95f3-d2403408b270', '28911e72-62a6-4426-a841-08401d8e42f7', 'It avoids using numbers entirely', FALSE, 3),
('c139c11b-454f-4cc9-98f3-cb15d6b7f38c', 'eedf8eb6-0f88-42da-9c82-8ec25032b04a', 'The set of all possible linear combinations of A''s columns', TRUE, 0),
('dd9e3e31-2f3d-46f2-b3b5-99dcfb06b399', 'eedf8eb6-0f88-42da-9c82-8ec25032b04a', 'The set of all rows of A written as columns', FALSE, 1),
('3045eb3c-0c1c-44a2-b620-d6401f35e3c8', 'eedf8eb6-0f88-42da-9c82-8ec25032b04a', 'Only the first column of A', FALSE, 2),
('b190a63a-47d1-41ae-90d4-f63cc4d6f11a', 'eedf8eb6-0f88-42da-9c82-8ec25032b04a', 'The determinant of A', FALSE, 3),
('ddfe32af-f97a-4c44-95b3-82c7ccdb4fdf', '46c7fd00-eb11-4e71-a821-43a1f84ee705', 'R^3', FALSE, 0),
('99e0ff94-2b64-44d9-92ff-82745196ad3d', '46c7fd00-eb11-4e71-a821-43a1f84ee705', 'R^5', TRUE, 1),
('beaae7cb-ff97-4666-9424-26da94e2a046', '46c7fd00-eb11-4e71-a821-43a1f84ee705', 'R^15', FALSE, 2),
('08c7de53-8307-4059-b533-ab214e12598e', '46c7fd00-eb11-4e71-a821-43a1f84ee705', 'R^8', FALSE, 3),
('52d2bf6e-403e-47d0-b0a7-0c5a28085f97', 'ff25ffac-412e-4595-8a60-ff6e7cc7a100', 'It tells you the size of matrix A', FALSE, 0),
('24e23ea4-d4d5-41b6-b0e2-45890ccf9f36', 'ff25ffac-412e-4595-8a60-ff6e7cc7a100', 'Ax = b has a solution exactly when b is in the column space of A', TRUE, 1),
('48e59165-ab2a-40a9-bcc0-1c909732ba64', 'ff25ffac-412e-4595-8a60-ff6e7cc7a100', 'It is unrelated to solving Ax = b', FALSE, 2),
('bccae77e-8600-4bfb-846d-59b2196b5298', 'ff25ffac-412e-4595-8a60-ff6e7cc7a100', 'It only matters for square matrices', FALSE, 3),
('72b785c7-096a-4345-a117-d4333b7fdd96', '1ad9af57-b27b-4888-b93f-a6fba402867a', 'The null space of A and the null space of A^T', TRUE, 0),
('52879807-6b16-47ee-ba2b-b773a7538921', '1ad9af57-b27b-4888-b93f-a6fba402867a', 'The eigenspace and the determinant space', FALSE, 1),
('a334a63c-218d-4e44-807d-26a0d4f2f009', '1ad9af57-b27b-4888-b93f-a6fba402867a', 'The identity space and the inverse space', FALSE, 2),
('3f27bfec-f0a8-4de7-9441-1fd171bcf367', '1ad9af57-b27b-4888-b93f-a6fba402867a', 'The diagonal space and the trace space', FALSE, 3),
('4c7573a0-9785-49f0-b8b8-fb534fc18453', 'd487065f-cce8-4ec6-b5c8-c068091b3b7c', 'R^m', FALSE, 0),
('95ab1b43-487b-4f50-a27a-4a083169ca55', 'd487065f-cce8-4ec6-b5c8-c068091b3b7c', 'R^n', TRUE, 1),
('fc5e5886-eb64-46bc-b7a7-6fcd7708c48a', 'd487065f-cce8-4ec6-b5c8-c068091b3b7c', 'R^(m+n)', FALSE, 2),
('40c839dd-0860-463d-a03e-44d493ed0e7a', 'd487065f-cce8-4ec6-b5c8-c068091b3b7c', 'R^(mn)', FALSE, 3),
('0aa92922-bc73-428b-9def-31be8699dc44', '6d72c47e-ae1b-4f1c-8af2-88f536b73f10', 'Equal to each other', FALSE, 0),
('e874fab7-781f-4f6f-89bc-106a35f15367', '6d72c47e-ae1b-4f1c-8af2-88f536b73f10', 'Orthogonal complements of each other in R^n', TRUE, 1),
('c553c467-a7c2-4a75-ab1e-64a29653f2f6', '6d72c47e-ae1b-4f1c-8af2-88f536b73f10', 'Always the same dimension as the column space', FALSE, 2),
('ffff2c53-0926-40b7-a07a-39964ac10c89', '6d72c47e-ae1b-4f1c-8af2-88f536b73f10', 'Unrelated subspaces', FALSE, 3),
('de284008-4905-4322-9db4-0bf3bfaebc6b', 'dd139d1f-3454-40ed-89b8-d4f08bdee0f2', 'u + v = 0', FALSE, 0),
('508d6fdd-0165-451f-836d-eb4d1d4b49fe', 'dd139d1f-3454-40ed-89b8-d4f08bdee0f2', 'Their dot product u . v = 0', TRUE, 1),
('e3b6d294-77e3-4263-995c-bbdf752b1d34', 'dd139d1f-3454-40ed-89b8-d4f08bdee0f2', 'They have the same length', FALSE, 2),
('67bc06fd-08bf-464f-b949-cfd726d8341a', 'dd139d1f-3454-40ed-89b8-d4f08bdee0f2', 'One is a scalar multiple of the other', FALSE, 3),
('09da78b8-a099-479f-b622-309718656064', 'aafdb775-7f76-4168-80b8-d2699dd6d513', 'A diagonal set', FALSE, 0),
('28b6bd53-37f8-465f-998e-2214ef93185e', 'aafdb775-7f76-4168-80b8-d2699dd6d513', 'An orthonormal set', TRUE, 1),
('4fd9311f-9742-4169-95d3-6ecff95358f0', 'aafdb775-7f76-4168-80b8-d2699dd6d513', 'An eigenbasis', FALSE, 2),
('7974814c-31bb-46cb-aa8e-7934464f69f5', 'aafdb775-7f76-4168-80b8-d2699dd6d513', 'A null set', FALSE, 3),
('826011d1-86c3-4300-a305-9059d6c067fa', 'c3355d3f-6048-48d4-ac68-497420c7f461', 'They make every matrix invertible automatically', FALSE, 0),
('a8424817-d0df-47fa-b77b-6e48360cf03c', 'c3355d3f-6048-48d4-ac68-497420c7f461', 'Computing coordinates and projections becomes much simpler (just dot products)', TRUE, 1),
('4bd38923-fd22-4f55-a1f9-cc567baaaff3', 'c3355d3f-6048-48d4-ac68-497420c7f461', 'They only exist for 2D vectors', FALSE, 2),
('5b263734-4a0d-424f-ab3c-629f2e175d70', 'c3355d3f-6048-48d4-ac68-497420c7f461', 'They eliminate the need for matrix multiplication', FALSE, 3),
('93d8ed03-2dae-4b73-aa83-e262d5955e8f', '94782da8-ffb4-45ae-8fde-049518c47dfe', 'Av = 0', FALSE, 0),
('9e3a5aa5-6a81-4940-afc0-c202f6be10b6', '94782da8-ffb4-45ae-8fde-049518c47dfe', 'Av is perpendicular to v', FALSE, 1),
('ede16bec-a1e6-4250-b2b0-f28448ef271d', '94782da8-ffb4-45ae-8fde-049518c47dfe', 'Av = λv for some scalar λ', TRUE, 2),
('764f879a-958b-4098-8e89-8040ed557c0a', '94782da8-ffb4-45ae-8fde-049518c47dfe', 'v has length 1', FALSE, 3),
('9c8795aa-4e0a-4117-8503-d42b42e389f6', 'a88e3f68-8593-49ed-81a6-1e5f00b9c28c', 'The determinant', FALSE, 0),
('05b0171b-2d69-40ae-b096-44bf8ad83b1e', 'a88e3f68-8593-49ed-81a6-1e5f00b9c28c', 'The eigenvalue', TRUE, 1),
('29785844-9cbc-490c-b819-d6f764fc5f1c', 'a88e3f68-8593-49ed-81a6-1e5f00b9c28c', 'The rank', FALSE, 2),
('dce9145c-1aec-4f3e-9ea5-f6eae663fcbc', 'a88e3f68-8593-49ed-81a6-1e5f00b9c28c', 'The trace', FALSE, 3),
('f3b90ab3-216d-4c5b-91ce-de2a2b77eb0e', 'e47346ce-e999-4908-9356-f2ed56108515', 'Rotated 90 degrees from the original', FALSE, 0),
('7e63e804-87fd-40c2-9fa2-e3f36f57ce55', 'e47346ce-e999-4908-9356-f2ed56108515', 'Always shorter than the original', FALSE, 1),
('c05466e1-bfd4-4595-9409-f3d4175180ff', 'e47346ce-e999-4908-9356-f2ed56108515', 'Pointing in the same (or exactly opposite) direction as the original, just scaled', TRUE, 2),
('d5103f23-9b39-4805-bea4-02717e12422a', 'e47346ce-e999-4908-9356-f2ed56108515', 'Always equal to the zero vector', FALSE, 3),
('6f11b9d8-83d6-4506-a447-33c8fb3ba267', '16c8423e-93d9-46a8-b229-4559fbe0f155', 'A = U Σ V^T', TRUE, 0),
('21af838f-27a8-450c-b941-f3726e6d169b', '16c8423e-93d9-46a8-b229-4559fbe0f155', 'A = A^2', FALSE, 1),
('eb0fdc56-4064-4574-bc66-da78401910e8', '16c8423e-93d9-46a8-b229-4559fbe0f155', 'A = L U', FALSE, 2),
('9a483f05-7729-4202-bf9c-c80c07fd7598', '16c8423e-93d9-46a8-b229-4559fbe0f155', 'A = Q R', FALSE, 3),
('f0a6771e-9463-44ea-95f2-6b19c0214b7a', '4397e4ab-edbb-4c56-91a7-ed07faf559b5', 'Only square matrices', FALSE, 0),
('c93faafd-99ac-47b1-8e8d-ab28179876ce', '4397e4ab-edbb-4c56-91a7-ed07faf559b5', 'Only invertible matrices', FALSE, 1),
('d1fcab58-2d54-48b8-9b37-af24897219b1', '4397e4ab-edbb-4c56-91a7-ed07faf559b5', 'Any m x n matrix, square or not', TRUE, 2),
('e4b62952-0e4c-408d-866b-b5d314a7bb9c', '4397e4ab-edbb-4c56-91a7-ed07faf559b5', 'Only matrices with positive entries', FALSE, 3),
('69f2c670-2411-4a8b-8093-909f8969f687', '5503d1c5-57d9-4d26-a6c4-400419d70ea6', 'Negative numbers', FALSE, 0),
('4e24a8cc-a143-4cd2-94f7-97243e1d0c9f', '5503d1c5-57d9-4d26-a6c4-400419d70ea6', 'Greater than or equal to zero', TRUE, 1),
('32feb0b3-afc0-4693-9da6-c08d3edd649a', '5503d1c5-57d9-4d26-a6c4-400419d70ea6', 'Complex numbers', FALSE, 2),
('5f1b5176-3e51-4839-a0fc-cb8148771a1a', '5503d1c5-57d9-4d26-a6c4-400419d70ea6', 'Equal to the eigenvalues of A', FALSE, 3),
('f779a978-50f8-4614-b5ae-100a38ee027f', '3ccd33aa-db31-4cf5-b74b-a46444d12ff2', 'Ax = b for some fixed b', FALSE, 0),
('ff741fa0-b666-46e0-bf1f-f944448a4332', '3ccd33aa-db31-4cf5-b74b-a46444d12ff2', 'Ax = 0', TRUE, 1),
('8a38c1f2-77ad-45e4-a530-a65cd8a17fbc', '3ccd33aa-db31-4cf5-b74b-a46444d12ff2', 'x = A', FALSE, 2),
('11f4729c-b119-41ad-a925-e8294551b882', '3ccd33aa-db31-4cf5-b74b-a46444d12ff2', 'Ax is maximized', FALSE, 3),
('809912ec-5524-4b09-bd9b-4879b4e9c9c5', '12eadade-56bd-46a2-8385-7e524a785ca9', 'Pivot columns', FALSE, 0),
('b84b5914-bf22-47c4-8653-074b0f68dde0', '12eadade-56bd-46a2-8385-7e524a785ca9', 'Columns without a pivot', TRUE, 1),
('66265e0f-c543-47d8-91fe-9cf50277c1e7', '12eadade-56bd-46a2-8385-7e524a785ca9', 'The rows of zeros only', FALSE, 2),
('efe416e8-475e-4e27-94ac-d23c7edd384b', '12eadade-56bd-46a2-8385-7e524a785ca9', 'The first column always', FALSE, 3),
('ece13f48-ec41-4c27-96ec-07f652857e82', 'a65e6b7c-f1c8-41d7-9770-9895d796e01e', 'All of R^n', FALSE, 0),
('3eb3481b-dc0d-4f27-9eda-fb5672106dcc', 'a65e6b7c-f1c8-41d7-9770-9895d796e01e', 'Just the zero vector', TRUE, 1),
('bcc3c889-eca8-4381-b59a-3c536c4c226c', 'a65e6b7c-f1c8-41d7-9770-9895d796e01e', 'Undefined for invertible matrices', FALSE, 2),
('f7267e5d-5a2d-404d-8f20-e1b7c16c0a35', 'a65e6b7c-f1c8-41d7-9770-9895d796e01e', 'The same as its column space', FALSE, 3),
('b38e8424-9322-400f-8093-45f3e16777a5', '2aca480b-640a-4f47-83f7-4c655721c311', 'Gaussian elimination', TRUE, 0),
('d81c2601-2719-4eef-a292-084eab58e098', '2aca480b-640a-4f47-83f7-4c655721c311', 'Computing eigenvalues', FALSE, 1),
('bfba26d5-6b8e-4077-9c8b-f4c1ba68de21', '2aca480b-640a-4f47-83f7-4c655721c311', 'Finding the null space', FALSE, 2),
('8dd8faf5-5064-450a-9905-72ff24013622', '2aca480b-640a-4f47-83f7-4c655721c311', 'Computing the determinant', FALSE, 3),
('d1340ce3-de01-45c6-9d84-3686d7511465', '049d6b85-0afd-426a-89f9-c6964ba087bc', 'A = QR', FALSE, 0),
('652bbff2-a891-4af4-94fa-6759d45c6f94', '049d6b85-0afd-426a-89f9-c6964ba087bc', 'A = LU', FALSE, 1),
('c21b3291-4fb8-41ac-a967-0b083599f523', '049d6b85-0afd-426a-89f9-c6964ba087bc', 'A = QΛQ^T (spectral/eigendecomposition)', TRUE, 2),
('330b1730-10b8-4cf6-9145-16e76d30e9b2', '049d6b85-0afd-426a-89f9-c6964ba087bc', 'A = CR', FALSE, 3),
('97341407-0c2d-4bde-9312-2ee136ccbfa9', '3f46c2eb-38b9-46b3-ba3e-c67d9262b7a8', 'Because matrices only have one true factorization and the rest are approximations', FALSE, 0),
('bb8a6570-d3ba-4a20-8054-e821be00dc03', '3f46c2eb-38b9-46b3-ba3e-c67d9262b7a8', 'Each factorization reveals different structural information and is suited to different problems', TRUE, 1),
('de9e4137-4290-445a-9f44-745240d70918', '3f46c2eb-38b9-46b3-ba3e-c67d9262b7a8', 'Factorizations are purely a notational convenience with no practical difference', FALSE, 2),
('0703f1fe-8f7e-4b0c-8958-0f30fb51e047', '3f46c2eb-38b9-46b3-ba3e-c67d9262b7a8', 'Only SVD is ever actually used in practice', FALSE, 3),
('0fb23b1d-7037-4a16-a185-5daf55b1e1f9', '33168d7a-a4bc-4b4c-ba10-6033f363328c', 'Has no exact solution, so we minimize the error instead', TRUE, 0),
('1f9746a2-47ec-4ce6-b58a-983498982c63', '33168d7a-a4bc-4b4c-ba10-6033f363328c', 'Always has exactly one exact solution', FALSE, 1),
('430f8569-df67-4af4-88a9-7f8cd4e6ba09', '33168d7a-a4bc-4b4c-ba10-6033f363328c', 'Is undefined unless A is square', FALSE, 2),
('ce812978-69e4-457b-87e2-891b39d961b1', '33168d7a-a4bc-4b4c-ba10-6033f363328c', 'Can only be solved by elimination', FALSE, 3),
('eaaf88e4-9794-4947-8fc9-5d0dd5822c65', '7faa6823-b8b5-4be6-8edd-5bd767efb522', 'A^T A x = A^T b (the normal equations)', TRUE, 0),
('27773e88-9517-49c8-ae82-c85a0fec79fb', '7faa6823-b8b5-4be6-8edd-5bd767efb522', 'A x = 0', FALSE, 1),
('6e75a169-2d2a-4f08-9ac0-56d09e4fc5ee', '7faa6823-b8b5-4be6-8edd-5bd767efb522', 'x = A b', FALSE, 2),
('b906dc23-eae6-41f8-9841-db84836143f9', '7faa6823-b8b5-4be6-8edd-5bd767efb522', 'A^2 x = b', FALSE, 3),
('bc692c7e-ffa6-4e88-b235-bf67a8685eff', '25329521-119b-4351-844f-e8514eccf403', 'Farthest from b', FALSE, 0),
('0dd2aed2-afa7-4506-a8be-b9734e61dbd0', '25329521-119b-4351-844f-e8514eccf403', 'Closest to b (the orthogonal projection of b)', TRUE, 1),
('05ea01e5-99dd-4abf-ac25-e74707c0af50', '25329521-119b-4351-844f-e8514eccf403', 'Equal to the zero vector', FALSE, 2),
('8aa58912-c2ba-48bc-a0c6-deb0befce3c8', '25329521-119b-4351-844f-e8514eccf403', 'Always equal to b itself', FALSE, 3),
('205c5d55-9b96-4484-b112-cb15c8fc3693', 'eda889ec-74a0-46bd-a01b-bf1d36c93e0f', 'A set of independent columns taken directly from A', TRUE, 0),
('9315c4d6-a150-40a1-958d-3231c33f431c', 'eda889ec-74a0-46bd-a01b-bf1d36c93e0f', 'The eigenvalues of A', FALSE, 1),
('67c2a843-016b-4bbc-9214-3b3b62796e02', 'eda889ec-74a0-46bd-a01b-bf1d36c93e0f', 'Random numbers unrelated to A', FALSE, 2),
('04e30531-73a4-422b-9082-d669777932c1', 'eda889ec-74a0-46bd-a01b-bf1d36c93e0f', 'The inverse of A', FALSE, 3),
('d927c5be-0ce1-41d1-a067-767c0c688f24', '9ab59c88-94ad-4245-ab88-4e238b7773cd', 'Eigendecomposition', FALSE, 0),
('4ab3a1cd-3832-4a02-abaa-e625c8651bda', '9ab59c88-94ad-4245-ab88-4e238b7773cd', 'Row reduction / elimination', TRUE, 1),
('e610b1f8-1554-4176-abd2-c19a4016c48f', '9ab59c88-94ad-4245-ab88-4e238b7773cd', 'Singular value decomposition', FALSE, 2),
('b811f734-cd07-4cbb-af4c-185935e97da2', '9ab59c88-94ad-4245-ab88-4e238b7773cd', 'Computing a determinant', FALSE, 3),
('816268e8-2195-47d2-8697-856da258c1d8', '81d92439-0a28-4c59-a631-c2eaf76c060b', 'The exact numerical inverse of any matrix', FALSE, 0),
('d29bef24-594e-4494-8793-1ba8057e3e3f', '81d92439-0a28-4c59-a631-c2eaf76c060b', 'The rank of A and a basis for its column space, without extra computation', TRUE, 1),
('800f3ba5-b75d-47b9-b07e-980eca36b587', '81d92439-0a28-4c59-a631-c2eaf76c060b', 'Only the size of matrix A', FALSE, 2),
('f0e974c8-a2cb-419b-a943-02a366a5ca2d', '81d92439-0a28-4c59-a631-c2eaf76c060b', 'The eigenvalues of A^2', FALSE, 3);


-- ---------------------------------------------------------------
-- fill_blank_questions
-- ---------------------------------------------------------------
INSERT INTO fill_blank_questions (question_id, case_sensitive) VALUES
('97973975-0bb7-4494-998f-aca25352b856', FALSE),
('c7e1c7f3-1e7f-4135-b1f2-ee0d30006318', FALSE),
('b9821f5a-758b-48b0-b7d7-5168a2248332', FALSE),
('12016df1-07bc-444d-8cbf-8b751ba9a647', FALSE),
('2b7efcbb-66ab-43cc-abe2-541993a7262c', FALSE),
('1e8c39b1-7fb8-405f-9d87-5c4972f6007a', FALSE),
('bc6c67fa-f1fb-46b3-95f6-8038db2eaab3', FALSE),
('c64701c3-7ae2-4f01-a2ca-cd5ad3b103eb', FALSE),
('23c025f6-6f7e-4ee4-b10c-c812d929c448', FALSE),
('3531019d-51f9-452f-aace-aae5d37efb15', FALSE),
('d13aa71a-b093-4e96-bbc5-5d612ef7a693', FALSE),
('6d96373f-8676-4d92-b906-2ff312d7f34f', FALSE),
('8f0b2387-ab08-4624-b1d5-77f598c536a1', FALSE),
('aa597010-bb09-4df4-b188-d37fdaa0a009', FALSE),
('2ea2936f-8c72-4dd1-ad84-25a378ba273d', FALSE),
('beb8e66f-e2d8-4a30-a5a1-34345e0b1e6e', FALSE),
('9c3660dc-4398-41b9-ab50-8abdea255757', FALSE),
('d5bd5ad6-3997-439f-aaca-16f7f08d995e', FALSE),
('f8b7241c-ef5b-4118-8687-87fbb49077de', FALSE),
('ffe90d6f-7a74-4603-a3c6-4c514476d59c', FALSE),
('d9f37f0b-77a7-4d44-9289-5ed608acdfcb', FALSE),
('d1ac1f91-4b31-4506-900b-7a9a4a798392', FALSE),
('efbe9d99-8aa3-400b-8467-7cd03cd54ad5', FALSE),
('fcda0436-e980-40cd-80ca-b832b17aa748', FALSE),
('8bb18816-509b-427b-ab48-1913be1205fc', FALSE),
('cf20f358-81d4-4e74-aa06-555fa8d3e7d2', FALSE),
('7e03c66b-46ac-4be9-94ec-e22a4e9114c7', FALSE),
('3edf32f0-beae-4f37-b4ef-0f4406ff87cb', FALSE),
('41ada8ab-4ce1-4f7f-9183-1b57eb2804cb', FALSE),
('c01a09e2-3263-4e64-b046-d7b38a2c1b9f', FALSE),
('cea1f259-9b42-48b9-a398-321ee65a06fc', FALSE),
('aa4875ff-eaae-4c1d-a110-1eb40e3d06d6', FALSE),
('b5c867d8-0266-4377-a2e9-641852f41c4b', FALSE),
('35c9baa1-b8fa-4b2f-ba58-45ef1a1ec7d4', FALSE),
('3d6c2824-b5cd-4d5e-a586-55cfa9e6cfc0', FALSE),
('8f4ccdaa-198c-4d90-b43e-e9ede067944f', FALSE),
('ea2d61e3-7d6e-4152-bccc-304c908dea6d', FALSE),
('7c32679d-7b78-492d-a1fe-3f15efd36316', FALSE),
('a0ed510c-c0f3-44a0-b715-4dade7a09138', FALSE);


-- ---------------------------------------------------------------
-- fill_blank_answers
-- ---------------------------------------------------------------
INSERT INTO fill_blank_answers (answer_id, question_id, answer_text) VALUES
('54f949ac-9ffb-4292-8809-d1989611f3b9', '97973975-0bb7-4494-998f-aca25352b856', '-8'),
('e23ebf0c-9993-4dfc-9c3c-c22934c9ef55', 'c7e1c7f3-1e7f-4135-b1f2-ee0d30006318', '3'),
('6b80b29a-e289-480a-a1c3-9f1bd8b992e3', 'b9821f5a-758b-48b0-b7d7-5168a2248332', '8'),
('001b9d74-83ab-4b98-a83c-ae7058fef83c', '12016df1-07bc-444d-8cbf-8b751ba9a647', '-2'),
('fb00335d-17e5-45a7-85de-da0680eb90fe', '2b7efcbb-66ab-43cc-abe2-541993a7262c', '1'),
('5b9b7e45-8d59-4704-a97d-a799b4bacdd8', '1e8c39b1-7fb8-405f-9d87-5c4972f6007a', '2'),
('d54f12a2-8542-41d6-a0d8-a8e00e0b8f15', 'bc6c67fa-f1fb-46b3-95f6-8038db2eaab3', '2'),
('7d591cae-1737-4614-a5db-041f18cb3dd0', 'c64701c3-7ae2-4f01-a2ca-cd5ad3b103eb', '1'),
('065e7b97-fa18-4696-88d7-bba9a883d188', '23c025f6-6f7e-4ee4-b10c-c812d929c448', '3'),
('804d0531-7213-4a9a-97f1-61a6112c6493', '3531019d-51f9-452f-aace-aae5d37efb15', '2'),
('a4e197f6-a03e-4528-82e0-d0d4906b74eb', 'd13aa71a-b093-4e96-bbc5-5d612ef7a693', '2'),
('263d67ad-6019-4a80-895d-f0240d456c51', '6d96373f-8676-4d92-b906-2ff312d7f34f', '1'),
('1f6e516c-3e56-4e7a-9637-0d9db1f4c112', '8f0b2387-ab08-4624-b1d5-77f598c536a1', '0'),
('8cefe960-9c6d-40d4-bcf7-e2dc9d9c6094', 'aa597010-bb09-4df4-b188-d37fdaa0a009', '5'),
('55414511-153b-4a11-ad30-6fa1897f2b46', '2ea2936f-8c72-4dd1-ad84-25a378ba273d', '1'),
('f71c8325-2388-41bd-bb88-2d466312bcc8', 'beb8e66f-e2d8-4a30-a5a1-34345e0b1e6e', '-1'),
('f76af9f5-f0b4-496e-beaa-718d3a2546e2', '9c3660dc-4398-41b9-ab50-8abdea255757', '5'),
('2b7d4587-6f78-45c5-9274-d6208c0ab26b', 'd5bd5ad6-3997-439f-aaca-16f7f08d995e', '2'),
('d0dce428-fcf4-4a8f-8286-6ef5bb7bd95b', 'f8b7241c-ef5b-4118-8687-87fbb49077de', '4'),
('090c2c7d-f3ee-4f32-b359-25aa771cf52d', 'ffe90d6f-7a74-4603-a3c6-4c514476d59c', '6'),
('2400d41a-ad33-403c-a164-faf32e3bd9a1', 'd9f37f0b-77a7-4d44-9289-5ed608acdfcb', '4'),
('6e5e40ca-e3b9-403f-8978-95558930a8fe', 'd1ac1f91-4b31-4506-900b-7a9a4a798392', '3'),
('dab784f8-d681-4181-81b1-dda330f62a94', 'efbe9d99-8aa3-400b-8467-7cd03cd54ad5', '6'),
('fb6adfd2-9060-4699-9b85-5234ab321b0e', 'fcda0436-e980-40cd-80ca-b832b17aa748', '49'),
('9575f245-d854-45bf-94da-5cd909898060', '8bb18816-509b-427b-ab48-1913be1205fc', '1'),
('0c37e454-46aa-495b-8f52-120381890c60', 'cf20f358-81d4-4e74-aa06-555fa8d3e7d2', '-1'),
('fc29154c-23c3-4aa2-b216-9b84e6c03cc2', '7e03c66b-46ac-4be9-94ec-e22a4e9114c7', '1'),
('b3e80aee-d3f9-40d4-93d4-8fa036ccccdb', '3edf32f0-beae-4f37-b4ef-0f4406ff87cb', '-2'),
('7b9282f7-bdc1-41f0-b398-95f6f40592db', '41ada8ab-4ce1-4f7f-9183-1b57eb2804cb', '2'),
('b05ef872-e94c-440a-aa0a-c2241e272c61', 'c01a09e2-3263-4e64-b046-d7b38a2c1b9f', '2'),
('afa936ba-9078-46e8-b578-7df805e282a8', 'cea1f259-9b42-48b9-a398-321ee65a06fc', '4'),
('ab0c5246-c6af-48a2-ac46-655cc34c638f', 'aa4875ff-eaae-4c1d-a110-1eb40e3d06d6', '-2'),
('755f0a3b-c72f-427a-9c8a-588d81dd77b3', 'b5c867d8-0266-4377-a2e9-641852f41c4b', '3'),
('a35407e6-8a1a-4f0b-92aa-853f9d7a19ea', '35c9baa1-b8fa-4b2f-ba58-45ef1a1ec7d4', '8'),
('8add7dbc-bac6-4742-8b2d-6127b8a7676c', '3d6c2824-b5cd-4d5e-a586-55cfa9e6cfc0', '2.5'),
('e45a1162-cd2d-46fa-8df3-1a9fbb86b823', '8f4ccdaa-198c-4d90-b43e-e9ede067944f', '1.5'),
('28bd9124-59b6-4a8d-9631-4d1fb5a9ed19', 'ea2d61e3-7d6e-4152-bccc-304c908dea6d', '1'),
('ad8da820-fecf-4e15-a657-cb70b9075b02', '7c32679d-7b78-492d-a1fe-3f15efd36316', '1'),
('4af24622-c282-4e7f-8d1c-ecec20bcd9e2', 'a0ed510c-c0f3-44a0-b715-4dade7a09138', '2');


SET FOREIGN_KEY_CHECKS = 1;


-- =====================================================================

-- TODO: update these placeholder durations (currently 600s = 10:00) with

-- the real YouTube video length before relying on duration-based UI:

-- =====================================================================

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = '14556ba6-5cf1-4208-b4cd-9c8c671c455a'; -- Intro: A New Way to Start Linear Algebra

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = 'a04679a2-2e90-4e60-a2af-42fbf940c2e5'; -- Part 1: The Column Space of a Matrix

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = '3e6e6d9a-abbf-4fe9-95f4-28f8f13a8a7a'; -- Part 2: The Big Picture of Linear Algebra

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = '86c23107-ebb3-494e-a0da-773edf42ce5b'; -- Part 3: Orthogonal Vectors

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = '1ccfe579-5573-4e83-b398-3bc5b66c0009'; -- Part 4: Eigenvalues and Eigenvectors

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = 'f34699ff-009b-40ee-858e-82564cb213f9'; -- Part 5: Singular Values and Singular Vectors

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = 'c593eab8-c41d-45da-9367-28e55c326fe7'; -- Part 6: Finding the Nullspace: Solving Ax = 0 by Elimination

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = 'a0d579f2-be6e-49ea-ba27-eeec3f8a44c8'; -- The Four Fundamental Subspaces and Least Squares

-- UPDATE learning_modules SET duration_secs = ??? WHERE module_id = '56a30a1a-3306-4c0f-895f-ac504eff2cd2'; -- Elimination and Factorization A = CR
