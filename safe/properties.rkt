#lang racket/base

;; Idiomatic SDL properties helpers

(require "../raw.rkt")

(provide make-properties
         destroy-properties!
         set-property-pointer!
         set-property-string!
         set-property-number!
         set-property-float!
         set-property-boolean!
         get-property-pointer
         get-property-string
         get-property-number
         get-property-float
         get-property-boolean)

;; Create a new properties group
(define (make-properties)
  (define props (SDL-CreateProperties))
  (when (zero? props)
    (error 'make-properties "Failed to create properties: ~a" (SDL-GetError)))
  props)

;; Destroy a properties group
(define (destroy-properties! props)
  (SDL-DestroyProperties props))

;; Setters
(define (set-property-pointer! props name value)
  (unless (SDL-SetPointerProperty props name value)
    (error 'set-property-pointer! "Failed to set pointer property: ~a" (SDL-GetError))))

(define (set-property-string! props name value)
  (unless (SDL-SetStringProperty props name value)
    (error 'set-property-string! "Failed to set string property: ~a" (SDL-GetError))))

(define (set-property-number! props name value)
  (unless (SDL-SetNumberProperty props name value)
    (error 'set-property-number! "Failed to set number property: ~a" (SDL-GetError))))

(define (set-property-float! props name value)
  (unless (SDL-SetFloatProperty props name (exact->inexact value))
    (error 'set-property-float! "Failed to set float property: ~a" (SDL-GetError))))

(define (set-property-boolean! props name value)
  (unless (SDL-SetBooleanProperty props name (and value #t))
    (error 'set-property-boolean! "Failed to set boolean property: ~a" (SDL-GetError))))

;; Getters
(define (get-property-pointer props name [default #f])
  (SDL-GetPointerProperty props name default))

(define (get-property-string props name [default ""])
  (SDL-GetStringProperty props name default))

(define (get-property-number props name [default 0])
  (SDL-GetNumberProperty props name default))

(define (get-property-float props name [default 0.0])
  (SDL-GetFloatProperty props name (exact->inexact default)))

(define (get-property-boolean props name [default #f])
  (SDL-GetBooleanProperty props name (and default #t)))
