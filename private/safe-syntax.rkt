#lang racket/base

;; Shared macros for safe SDL3 wrappers

(require (for-syntax racket/base
                     racket/syntax)
         ffi/unsafe
         ffi/unsafe/custodian)

(provide define-sdl-resource
         define-enum-conversion)

;; ============================================================================
;; Resource Wrapper Macro
;; ============================================================================

;; Define an SDL resource type with automatic custodian cleanup
;;
;; (define-sdl-resource name destructor-fn)
;;
;; Generates:
;;   - (struct name (ptr [destroyed? #:mutable]) ...)
;;   - (name-destroy! obj) - manual destructor
;;   - (wrap-name ptr #:custodian cust) - wrap a pointer with cleanup
;;
;; Example:
;;   (define-sdl-resource texture SDL-DestroyTexture)
;;
(define-syntax (define-sdl-resource stx)
  (syntax-case stx ()
    [(_ name destructor)
     (with-syntax ([name? (format-id #'name "~a?" #'name)]
                   [name-ptr (format-id #'name "~a-ptr" #'name)]
                   [name-destroyed? (format-id #'name "~a-destroyed?" #'name)]
                   [set-name-destroyed?! (format-id #'name "set-~a-destroyed?!" #'name)]
                   [name-destroy! (format-id #'name "~a-destroy!" #'name)]
                   [wrap-name (format-id #'name "wrap-~a" #'name)])
       #'(begin
           ;; The struct type with cpointer property for transparent FFI use
           (struct name (ptr [destroyed? #:mutable])
             #:property prop:cpointer (λ (obj) (name-ptr obj)))

           ;; Manual destructor
           (define (name-destroy! obj)
             (unless (name-destroyed? obj)
               (destructor (name-ptr obj))
               (set-name-destroyed?! obj #t)))

           ;; Wrap a pointer and register with custodian
           (define (wrap-name ptr #:custodian [cust (current-custodian)])
             (define obj (name ptr #f))
             (register-custodian-shutdown obj name-destroy! cust #:at-exit? #t)
             obj)))]))

;; ============================================================================
;; Enum Conversion Macro
;; ============================================================================

;; Define bidirectional conversion between symbols and SDL constants
;;
;; (define-enum-conversion name
;;   ([sym ...] constant)
;;   ...)
;;
;; Generates:
;;   - (symbol->name sym) - convert symbol to constant
;;   - (name->symbol val) - convert constant to symbol
;;
;; The first symbol in each group is the canonical symbol returned by name->symbol.
;; Additional symbols are aliases accepted by symbol->name.
;;
;; Example:
;;   (define-enum-conversion blend-mode
;;     ([none] SDL_BLENDMODE_NONE)
;;     ([blend alpha] SDL_BLENDMODE_BLEND)  ; 'alpha is alias for 'blend
;;     ([add additive] SDL_BLENDMODE_ADD))
;;
(define-syntax (define-enum-conversion stx)
  (syntax-case stx ()
    [(_ name ([sym0 sym ...] constant) ...)
     (with-syntax ([symbol->name (format-id #'name "symbol->~a" #'name)]
                   [name->symbol (format-id #'name "~a->symbol" #'name)])
       #'(begin
           (define (symbol->name sym-arg)
             (case sym-arg
               [(sym0 sym ...) constant] ...
               [else (error 'symbol->name "unknown ~a: ~a" 'name sym-arg)]))
           (define (name->symbol val)
             (cond
               [(= val constant) 'sym0] ...  ; Uses first symbol as canonical
               [else 'unknown]))))]))
