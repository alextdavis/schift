;;
;; Implements Scheme math functions
;;
;; @author Anna S. Johnson
;; @author Eva D. Grench
;; @author Alex T. Davis
;;

;; Implements the zero? function
(define zero?
 (lambda (arg)
  (= arg 0)))

;; Implements the number? function
(define number?
 (lambda (arg)
  (or (integer? arg) (double? arg))))

;; Implements the not function
(define not
 (lambda (e)
  (if e
   #f
   #t)))

;; Implements the < function
(define <
 (lambda args
  (and (apply <= args) (not (apply = args)))))

;; Implements the > function
(define >
 (lambda args
  (not (apply <= args))))

;; Implements the >= function
(define >=
 (lambda args
  (not (apply < args))))

;; Implements the modulo function
(define modulo
 (lambda (num1 num2)
  (- num1 (* (floor (/ num1 num2)) num2))))

;; Implements the positive? function
(define positive?
 (lambda (num)
  (> num 0)))

;; Implements the negative? function
(define negative?
 (lambda (num)
  (< num 0)))

;; Implements the even? function
;; Returns false in the case of a double that cannot be simplified to an integer
(define even?
 (lambda (num)
  (if (integer? num)
   (= (modulo num 2) 0) #f)))

;; Implements the odd? function
;; Returns false in the case of a double that cannot be simplified to an integer
(define odd?
 (lambda (num)
  (if (integer? num)
  (not (= (modulo num 2) 0)) #f)))

;; Implements the equal? function
(define equal?
 (lambda (lhs rhs)
  (if (and (pair? lhs) (pair? rhs))
   (and (equal? (car lhs) (car rhs))
    (equal? (cdr lhs) (cdr rhs)))
   (if (and (number? lhs) (number? rhs))
    (= lhs rhs) (eq? lhs rhs)))))

;; Implements the max function
(define max
 (lambda args
  (max-helper (car args) (cdr args))))

;; Helper function for max
(define max-helper
 (lambda (max-num nums)
  (cond
   ((null? nums) max-num)
   ((> (car nums) max-num) (max-helper (car nums) (cdr nums)))
   (else (max-helper max-num (cdr nums))))))

;; Implements the min function
(define min
 (lambda args
  (min-helper (car args) (cdr args))))

;; Helper function for min
(define min-helper
 (lambda (min-num nums)
  (cond
   ((null? nums) min-num)
   ((< (car nums) min-num) (min-helper (car nums) (cdr nums)))
   (else (min-helper min-num (cdr nums))))))

;;;; Implements the abs function
(define abs
 (lambda (num)
  (if (negative? num)
   (* num -1)
   num)))

;; Implements the ceiling function
(define ceiling
 (lambda (num)
  (if (integer? num)
   num
   (+ (floor num) 1))))
