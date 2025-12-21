#lang racket/base

;; Idiomatic dialog boxes - message boxes, confirmations, and file dialogs

(require ffi/unsafe
         racket/match
         "../raw.rkt"
         "window.rkt")

(provide
 ;; Simple message boxes
 show-message-box

 ;; Confirmation dialogs
 show-confirm-dialog

 ;; File dialogs
 open-file-dialog
 save-file-dialog
 open-folder-dialog)

;; ============================================================================
;; Helper: extract window pointer
;; ============================================================================

;; Accepts window struct, raw pointer, or #f
;; Returns the raw pointer for passing to SDL functions
(define (extract-window-ptr w)
  (cond
    [(not w) #f]
    [(window? w) (window-ptr w)]
    [else w]))  ; assume it's already a raw pointer

;; ============================================================================
;; Simple Message Boxes
;; ============================================================================

;; show-message-box: Display a simple message box
;; title: the dialog title
;; message: the message text
;; #:type: 'info, 'warning, or 'error (default: 'info)
;; #:window: optional parent window (window struct or #f)
;; Returns: #t on success, #f on failure
(define (show-message-box title message
                          #:type [type 'info]
                          #:window [window #f])
  (define flags
    (case type
      [(info information) SDL_MESSAGEBOX_INFORMATION]
      [(warning warn) SDL_MESSAGEBOX_WARNING]
      [(error err) SDL_MESSAGEBOX_ERROR]
      [else (error 'show-message-box
                   "invalid type: ~a (expected 'info, 'warning, or 'error)"
                   type)]))
  (SDL-ShowSimpleMessageBox flags title message (extract-window-ptr window)))

;; ============================================================================
;; Confirmation Dialogs
;; ============================================================================

;; show-confirm-dialog: Display a confirmation dialog with custom buttons
;; title: the dialog title
;; message: the message text
;; #:buttons: button configuration - one of:
;;   'yes-no         -> Yes/No buttons, returns 'yes or 'no
;;   'yes-no-cancel  -> Yes/No/Cancel buttons, returns 'yes, 'no, or 'cancel
;;   'ok-cancel      -> OK/Cancel buttons, returns 'ok or 'cancel
;;   'ok             -> Single OK button, returns 'ok
;; #:type: 'info, 'warning, or 'error (default: 'info)
;; #:window: optional parent window (window struct or #f)
;; Returns: symbol indicating which button was clicked, or #f on failure
(define (show-confirm-dialog title message
                             #:buttons [buttons 'yes-no]
                             #:type [type 'info]
                             #:window [window #f])
  (define flags
    (case type
      [(info information) SDL_MESSAGEBOX_INFORMATION]
      [(warning warn) SDL_MESSAGEBOX_WARNING]
      [(error err) SDL_MESSAGEBOX_ERROR]
      [else (error 'show-confirm-dialog
                   "invalid type: ~a (expected 'info, 'warning, or 'error)"
                   type)]))

  ;; Define button configurations
  ;; Each config is: (list of (id . label) pairs, return-key-id, escape-key-id)
  (define-values (button-specs return-id escape-id)
    (case buttons
      [(yes-no)
       (values '((0 . "No") (1 . "Yes")) 1 0)]
      [(yes-no-cancel)
       (values '((0 . "Cancel") (1 . "No") (2 . "Yes")) 2 0)]
      [(ok-cancel)
       (values '((0 . "Cancel") (1 . "OK")) 1 0)]
      [(ok)
       (values '((0 . "OK")) 0 0)]
      [else
       (error 'show-confirm-dialog
              "invalid buttons: ~a (expected 'yes-no, 'yes-no-cancel, 'ok-cancel, or 'ok)"
              buttons)]))

  ;; Create button array
  (define num-buttons (length button-specs))
  (define buttons-array
    (cast (malloc (* num-buttons (ctype-sizeof _SDL_MessageBoxButtonData)) 'atomic)
          _pointer _SDL_MessageBoxButtonData-pointer))

  ;; Fill in button data
  (for ([spec (in-list button-specs)]
        [i (in-naturals)])
    (define id (car spec))
    (define label (cdr spec))
    (define btn-flags
      (bitwise-ior
       (if (= id return-id) SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT 0)
       (if (= id escape-id) SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT 0)))
    (ptr-set! buttons-array _SDL_MessageBoxButtonData i
              (make-SDL_MessageBoxButtonData btn-flags id label)))

  ;; Create message box data
  (define msgbox-data
    (make-SDL_MessageBoxData
     flags
     (extract-window-ptr window)
     title
     message
     num-buttons
     buttons-array
     #f))  ; no custom color scheme

  ;; Show dialog and get result
  (define-values (success button-id)
    (SDL-ShowMessageBox msgbox-data))

  ;; Convert button ID to symbol
  (if success
      (case buttons
        [(yes-no)
         (case button-id [(0) 'no] [(1) 'yes] [else #f])]
        [(yes-no-cancel)
         (case button-id [(0) 'cancel] [(1) 'no] [(2) 'yes] [else #f])]
        [(ok-cancel)
         (case button-id [(0) 'cancel] [(1) 'ok] [else #f])]
        [(ok)
         (case button-id [(0) 'ok] [else #f])]
        [else #f])
      #f))

;; ============================================================================
;; File Dialogs
;; ============================================================================

;; Helper: wait for a semaphore while pumping SDL events
;; This is necessary because file dialogs on macOS need the event loop running
(define (wait-with-event-pump sema)
  (let loop ()
    (unless (semaphore-try-wait? sema)
      (SDL-PumpEvents)
      (sleep 0.01)  ; Small delay to avoid busy-waiting
      (loop))))

;; Helper: parse filelist pointer from callback
;; Returns #f for NULL (error), '() for pointer to NULL (canceled),
;; or list of strings for selected files
(define (parse-filelist filelist-ptr)
  (cond
    [(not filelist-ptr) #f]  ; NULL = error
    [else
     ;; Check if first element is NULL (canceled)
     (define first (ptr-ref filelist-ptr _pointer 0))
     (if (not first)
         '()  ; pointer to NULL = canceled
         ;; Read null-terminated array of strings
         (let loop ([i 0] [acc '()])
           (define ptr (ptr-ref filelist-ptr _pointer i))
           (if (not ptr)
               (reverse acc)
               (loop (add1 i)
                     (cons (cast ptr _pointer _string/utf-8) acc)))))]))

;; Helper: create filter array from list of (name . pattern) pairs
;; Returns (values filter-ptr count) where filter-ptr may be #f
(define (make-filter-array filters)
  (cond
    [(or (not filters) (null? filters))
     (values #f 0)]
    [else
     (define count (length filters))
     (define filter-ptr
       (cast (malloc (* count (ctype-sizeof _SDL_DialogFileFilter)) 'atomic)
             _pointer _SDL_DialogFileFilter-pointer))
     (for ([f (in-list filters)]
           [i (in-naturals)])
       (match-define (cons name pattern) f)
       (ptr-set! filter-ptr _SDL_DialogFileFilter i
                 (make-SDL_DialogFileFilter name pattern)))
     (values filter-ptr count)]))

;; open-file-dialog: Display a file open dialog
;; #:filters: list of (name . pattern) pairs, e.g., '(("Images" . "png;jpg;gif"))
;; #:default-path: starting folder/file path
;; #:allow-multiple?: if #t, allow selecting multiple files
;; #:window: parent window (window struct or #f)
;; Returns: path-string, (listof path-string), or #f if canceled/error
(define (open-file-dialog #:filters [filters '()]
                          #:default-path [default-path #f]
                          #:allow-multiple? [allow-multiple? #f]
                          #:window [window #f])
  ;; Use a semaphore + box to wait for async callback
  (define result-box (box #f))
  (define done-sema (make-semaphore 0))

  ;; Create callback that stores result and signals completion
  (define (callback userdata filelist-ptr filter-idx)
    (set-box! result-box (parse-filelist filelist-ptr))
    (semaphore-post done-sema))

  ;; Create filter array
  (define-values (filter-ptr filter-count) (make-filter-array filters))

  ;; Show dialog (async)
  (SDL-ShowOpenFileDialog callback
                          #f              ; userdata
                          (extract-window-ptr window)
                          filter-ptr
                          filter-count
                          default-path
                          allow-multiple?)

  ;; Wait for callback while pumping events
  (wait-with-event-pump done-sema)

  ;; Return result
  (define result (unbox result-box))
  (cond
    [(not result) #f]           ; error
    [(null? result) #f]         ; canceled
    [(and (not allow-multiple?) (= (length result) 1))
     (car result)]              ; single file
    [else result]))             ; multiple files

;; save-file-dialog: Display a file save dialog
;; #:filters: list of (name . pattern) pairs
;; #:default-path: starting folder/file path
;; #:window: parent window (window struct or #f)
;; Returns: path-string or #f if canceled/error
(define (save-file-dialog #:filters [filters '()]
                          #:default-path [default-path #f]
                          #:window [window #f])
  ;; Use a semaphore + box to wait for async callback
  (define result-box (box #f))
  (define done-sema (make-semaphore 0))

  ;; Create callback that stores result and signals completion
  (define (callback userdata filelist-ptr filter-idx)
    (set-box! result-box (parse-filelist filelist-ptr))
    (semaphore-post done-sema))

  ;; Create filter array
  (define-values (filter-ptr filter-count) (make-filter-array filters))

  ;; Show dialog (async)
  (SDL-ShowSaveFileDialog callback
                          #f              ; userdata
                          (extract-window-ptr window)
                          filter-ptr
                          filter-count
                          default-path)

  ;; Wait for callback while pumping events
  (wait-with-event-pump done-sema)

  ;; Return result
  (define result (unbox result-box))
  (cond
    [(not result) #f]           ; error
    [(null? result) #f]         ; canceled
    [else (car result)]))       ; selected file

;; open-folder-dialog: Display a folder selection dialog
;; #:default-path: starting folder path
;; #:allow-multiple?: if #t, allow selecting multiple folders
;; #:window: parent window (window struct or #f)
;; Returns: path-string, (listof path-string), or #f if canceled/error
(define (open-folder-dialog #:default-path [default-path #f]
                            #:allow-multiple? [allow-multiple? #f]
                            #:window [window #f])
  ;; Use a semaphore + box to wait for async callback
  (define result-box (box #f))
  (define done-sema (make-semaphore 0))

  ;; Create callback that stores result and signals completion
  (define (callback userdata filelist-ptr filter-idx)
    (set-box! result-box (parse-filelist filelist-ptr))
    (semaphore-post done-sema))

  ;; Show dialog (async)
  (SDL-ShowOpenFolderDialog callback
                            #f              ; userdata
                            (extract-window-ptr window)
                            default-path
                            allow-multiple?)

  ;; Wait for callback while pumping events
  (wait-with-event-pump done-sema)

  ;; Return result
  (define result (unbox result-box))
  (cond
    [(not result) #f]           ; error
    [(null? result) #f]         ; canceled
    [(and (not allow-multiple?) (= (length result) 1))
     (car result)]              ; single folder
    [else result]))             ; multiple folders
