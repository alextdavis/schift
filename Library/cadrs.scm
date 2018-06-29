;;
;; Implements variations on car and cdr
;;
;; @author Anna S. Johnson
;; @author Eva D. Grench
;; @author Alex T. Davis
;;

(define cadr
 (lambda (lst)
  (car (cdr lst))))

(define cddr
 (lambda (lst)
  (cdr (cdr lst))))

(define caddr
 (lambda (lst)
  (car (cdr (cdr lst)))))

(define cdddr
 (lambda (lst)
  (cdr (cdr (cdr lst)))))

(define cadddr
 (lambda (lst)
  (car (cdr (cdr (cdr lst))))))

(define cddddr
 (lambda (lst)
  (cdr (cdr (cdr (cdr lst))))))

(define caddddr
 (lambda (lst)
  (car (cdr (cdr (cdr (cdr lst)))))))

(define cdddddr
 (lambda (lst)
  (cdr (cdr (cdr (cdr (cdr lst)))))))

(define cadddddr
 (lambda (lst)
  (car (cdr (cdr (cdr (cdr (cdr lst))))))))

(define cddddddr
 (lambda (lst)
  (cdr (cdr (cdr (cdr (cdr (cdr lst))))))))
