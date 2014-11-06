;;; .emacs -*-Emacs-Lisp-*-         created:  Fri Oct 10 23:03:43 1998
; $Id$
;; function definitions:

(defun number-to-hex-string (num)
  "Convert a number NUM to a string which represents the number in hex."
  (concat "0x" (upcase (format "%08X" num))))

(defun hex-string-to-number (str)
  "Convert a string STR which represents a number in hex to a number.
NB:  Emacs uses 5 bits for type information and garbage collection;
thus, this will work incorrectly for numbers greater than 0x7FFFFFF
on a 32-bit machine, as such numbers can not be represented as Lisp
'number objects' in Emacs.  Don't use this for pointer calculations."
  (cond
   ((equal str "") 0)
   ((equal (substring str 0 1) "-")
    (- 0 (hex-string-to-number (substring str 1))))
   ((and (>= (length str) 2) (equal (substring str 0 2) "0x"))
    (hex-string-to-number (substring str 2)))
   (t
    (let* ((n (string-to-char (upcase (substring str -1)))))
      (cond 
       ((and (>= n (string-to-char "0")) (<= n (string-to-char "9")))
        (+ (- n (string-to-char "0"))
           (* 16 (hex-string-to-number (substring str 0 -1)))))
       ((and (>= n (string-to-char "A")) (<= n (string-to-char "Z")))
        (+ (- (+ 10 n) (string-to-char "A"))
           (* 16 (hex-string-to-number (substring str 0 -1))))))))))

; (+ 1 134217727)

(defun forward-number (arg)
  "Moves forward until a non-numeric character found.
Meant for use with thing-at-point, ie (thing-at-point 'number)."
  (interactive "p")
  (if (> arg 0)
      (skip-chars-forward "0-9\\-")
    (skip-chars-backward "0-9\\-")))
(defun number-at-point () (thing-at-point 'number))

; nvi has the useful '#' command
(defun increment-number-at-point (arg)
  "Increment the number at the point.  With ARG, add ARG to the number."
  (interactive "p")
  (save-excursion
    (let ((n (string-to-number (thing-at-point 'number)))
          (cell (bounds-of-thing-at-point 'number)))
      (delete-region (car cell) (cdr cell))
      (insert (format "%d" (+ arg n))))))

(defun c-center-comment (s)
  "Insert a pretty one line C comment."
  (interactive "sCenter text:  ")
  (if (> (length s) (- fill-column 6))
      (error "String too long")
    (setq s (concat " " s " "))
    (while (< (length s) fill-column)
      (setq s (concat "*" s "*")))
    (setq s (concat "/" s "/"))
    (insert s)))

(defun do-c-header-file ()
  "Insert #ifndefs for a C header file."
  (interactive)
  (save-excursion
    (let (header-name)
      (string-match "\\(.*\\)\\.\\(.*\\)" buffer-file-name)
      (setq header-name
            (concat (substring buffer-file-name 0 (match-end 1))
                    "_"
                    (substring buffer-file-name (1+ (match-end 1)) 
                               (match-end 2))))
      (setq header-name (upcase (substring header-name
                                           (string-match "[^/]*$"
                                                         header-name))))
      (insert "#ifndef " header-name "\n#define " header-name "\n\n")
      (goto-char (point-max))
      (insert "#endif /* " header-name " */"))))

(defun insert-ifdef (start end)
  "Surround the region with a C preprocessor conditional"
  (interactive "r")
  (let ((s (read-from-minibuffer "Insert: "))
        (l (count-lines 0 end))
    (goto-char end)
    (end-of-line)
    (insert "\n#endif /* " s " */")
    (goto-char start)
    (beginning-of-line)
    (insert "#ifdef " s "\n")
    (goto-line (+l 2)))))

(defun fix-camel (start end) ; FIXME:  gets confused sometimes
  "Change region from CamelBackStyleNotation to c_style_notation.
Use only in C-mode, or something which considers \"_\" a valid
identifier character."
  (interactive "r")
  (save-excursion
    (let (saved)
      (goto-char start)
      (while (re-search-forward "[A-Z][a-z_]*[A-Z]" end t 1)
        (setq saved (thing-at-point 'symbol))
        (forward-word -1)
        (kill-word 1)
        (insert (concat (downcase (substring saved 0 1))
                        (substring saved 1))))
      (goto-char start)
      (while (re-search-forward "[a-z][A-Z]" end t 1)
        (backward-char)
        (setq saved (thing-at-point 'char))
        (delete-char 1)
        (insert "_" (downcase saved))))))

(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

(defun map-macro (the-macro items)
  "Apply THE-MACRO to each item in ITEMS.
(\\[mapcar] uses APPLY, which does not play nice with macros)."
  (if (null items)
      nil
    (progn
      (eval `(,the-macro ,(car items)))
      (map-macro the-macro (cdr items)))))

(defun expand-last-match (num string)
  "Return the specified text matched by last regexp match.
NUM, a number, specifies which parenthesized expression in the
regexp performed.  STRING is the string over which the last
\\[string-match] was performed.  If NUM is zero, the entire match
is returned. If NUM was not matched as a parenthesized expression,
returns nil."
  (and (match-beginning num)
       (match-end num)
       (substring string (match-beginning num) (match-end num))))

(defun split (regexp string)
  "Split STRING into a list using REGEXP (just like Perl's 'split')
Example:  (split \":\" \"/bin:/usr/bin:/usr/ucb\")
=> (\"/bin\" \"/usr/bin\" \"/usr/ucb\")"
  (let ((r (concat "\\(" regexp "\\)?\\(.*\\)" regexp "\\(.*\\)")))
    (defun do-it (s)
      (if (string-match r s)
          (cons (expand-last-match 3 s)
                (do-it (expand-last-match 2 s)))
        (list s)))
    (nreverse (do-it string))))

(require 'cl)
(defun in-path-p (file)
  "Return t if FILE is somewhere in your PATH and executable by you."
  (not (null (delete-if-not (lambda (x)
                              (file-executable-p (concat x "/" file)))
                            (split ":" (getenv "PATH"))))))

(defun fix-keys ()
  "For use only with Windows telnet (best avoided at all costs)."
  (interactive)
  (global-set-key "\C-ch" 'help)
  (global-set-key "\C-\M-h" 'backward-kill-word)
  (keyboard-translate ?\C-h ?\C-?)
  (message "Now C-c h is help, and C-h is delete"))

(defun kill-bottom-buffer-and-window ()
  "Kill the bottom buffer and window (use only with 2 windows)."
  (interactive)
  (if (= (car (cdr (window-edges))) 0)
      (other-window 1))
  (kill-buffer (current-buffer))
  (other-window 1)
  (delete-other-windows))

;; from emacswiki/SwitchingWindows
(defun switch-to-window-number (number)
  "Switch to the nth window"
  (interactive "P")
  (if (integerp number)
      (select-window (nth number (window-list)))))
; (global-set-key "\C-cj" 'switch-to-window-number)

(mapcar
 (lambda (n)
   (global-set-key (concat "\C-cj" (number-to-string n))
                   (lambda nil (interactive) (switch-to-window-number n))))
 '(1 2 3 4 5 6 7 8 9))

;; from emacswiki
(defun fullscreen (&optional f)
  (interactive)
  (set-frame-parameter f 'fullscreen
                       (if (frame-parameter f 'fullscreen) nil 'fullboth)))
(global-set-key [f11] 'fullscreen)
(add-hook 'after-make-frame-functions 'fullscreen)

(defun axh-dired-open-files (client-root)
  "Open a dired buffer containing already-open files with a common prefix."
  (interactive "D Common directory (eg: google3 client root): ")
  (let ((list-of-files
         (delete-if
          'not
          (mapcar (lambda (f)
                    (string-replace-match client f ""))
                  (delete-if
                   'not
                   (mapcar 'buffer-file-name
                           (delete-if
                            (lambda (b)
                              (with-current-buffer
                                  b buffer-read-only))
                            (buffer-list))))))))
    (dired (cons client list-of-files))))

; FIXME:  surely these must already exist under some other name?
(defun shrink-list (len lst)
  (if (= len 0) nil
    (cons (car lst) (shrink-list (- len 1) (cdr lst)))))
(defun all-but-last (lst)
  (shrink-list (- (length lst) 1) lst))

(defvar default-date-format "%c" "Default format for inserting date")
(defun insert-date (&optional arg)
  "Insert the date.
If ARG is non-nil, then use ARG as argument to \\[format-time-string],
else use \"default-date-format\" as format string."
  (interactive)
  (insert (format-time-string (or arg default-date-format))))

(defun insert-right-justified (str)
  "Insert STR right-justified on current line; pads with spaces."
  (save-excursion
    (end-of-line)
    (if (> fill-column (+ (current-column) (length str)))
        (progn
          (while (not (= (- fill-column
                            (+ (current-column)
                               (length str))) 0))
            (insert " "))
          (insert str))
      (error "Not enough room"))))

(defun region-command-on-word (cmd)
  "Perform CMD using the current word as the region for its arguments."
  (interactive)
  (save-excursion
    (let ((beg nil))
      (forward-word -1)
      (setq beg (point))
      (forward-word 1)
      (funcall cmd beg (point)))))

(defun go-up ()
  (interactive)
  (and (not (pos-visible-in-window-p (point-min)))
       (scroll-down 1))
  (next-line -1))

(defun go-down ()
  (interactive)
  (let ((old-point (point)))
    (scroll-down -1)
    (and (pos-visible-in-window-p old-point)
         (next-line 1))))

(defun hungry-backspace ()
  (interactive)
  (backward-char 1)
  (if (looking-at " \\|\n\\|\t")
      (progn
        (while (looking-at " \\|\n\\|\t")
          (delete-char 1)
          (backward-char 1))
        (forward-char 1))
    (delete-char 1)))

(defun axh-comment-region (start end &optional arg)
  (interactive "r\nP")
  (or comment-start
      (progn
        (setq comment-start (read-from-minibuffer "Start comments with:  "))
        (setq comment-end   (read-from-minibuffer "End comments with:  "))))
  (comment-region start end arg))

; from: http://everything2.com/title/useful+emacs+lisp+functions
(defun create-scratch-buffer nil
  "create a new scratch buffer to work in. (could be *scratch* - *scratchX*)"
  (interactive)
  (let ((n 0)
	bufname)
    (while (progn
	     (setq bufname (concat "*scratch"
				   (if (= n 0) "" (int-to-string n))
				   "*"))
	     (setq n (1+ n))
	     (get-buffer bufname)))
    (switch-to-buffer (get-buffer-create bufname))
    (if (= n 1) (lisp-interaction-mode)) ; 1, because n was incremented
    ))

; The following based upon maniac.el, written by Per Abrahamsen in
; 1994, public domain
;; -- start maniac --
(defvar maniac-fill-mode nil)
(make-variable-buffer-local ' maniac-fill-mode)

(defun do-maniac-fill ()
  ;; Do an auto fill if maniac fill mode is on.
  (if (or (not maniac-fill-mode)
	  (and (eolp)
	       (memq (preceding-char)
		     '(0 ?\n ?\t ? ))))
      ()
    (fill-paragraph nil)))

;; Call maniac fill after each command.
(add-hook 'post-command-hook 'do-maniac-fill)

;; Add to mode line.
(or (assq 'maniac-fill-mode minor-mode-alist)
    (setq minor-mode-alist
	  (cons '(maniac-fill-mode (" Maniac"))
		minor-mode-alist)))

(defun maniac-fill-mode (&optional arg)
  "Toggle maniac fill mode.
With prefix arg, turn maniac fill mode on iff arg is positive.

When maniac fill mode is on, the current paragraph will be formatted
after each command."
  (interactive "P")
  (setq maniac-fill-mode (not (or (and (null arg) maniac-fill-mode)
				  (<= (prefix-numeric-value arg) 0))))
  (set-buffer-modified-p (buffer-modified-p)))
; (add-hook 'text-mode-hook 'maniac-fill-mode)
;; -- end maniac --

;; global key bindings

(global-set-key "\C-ha" 'apropos)
(global-set-key "\C-ch" 'help)
(global-set-key "\C-l" 'redraw-display)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-x\C-b" 'electric-buffer-list)
(global-set-key "\C-xm" 'vm-mail)
(global-set-key "\M-i" 'indent-relative)
(global-set-key "\M-k" 'kill-buffer)
(global-set-key "\M-z" 'go-up)
(global-set-key "\C-z" 'go-down)
(global-set-key "\C-x\C-^" 'enlarge-window)
;(global-set-key "\M-[" 'align)
(global-set-key "\C-h a" 'apropos)
(global-set-key [C-tab] 'dabbrev-expand)
;(global-set-key [?\C-;] 'axh-comment-region)
(global-set-key [?\C-c 35] 'increment-number-at-point) ; 35 = '#'
(global-set-key [C-backspace] 'hungry-backspace)
(global-set-key [?\C-=] (function (lambda () (interactive)
                                    (manual-entry (current-word)))))
(global-set-key "\C-x2" (function (lambda () (interactive)
                                    (split-window-vertically -14))))
(global-set-key "\C-xi" (function (lambda() (interactive)
                                    (other-window -1))))
; unbound: [?\C-`] M-o M-p M-s M-n M-[ M-] M-? M-+ M-_
(global-set-key "\C-cw" 'compare-windows)
(global-set-key "\C-cd" 'insert-date)
(global-set-key "\C-ce" (function (lambda () (interactive)
                                    (insert-right-justified
                                     (concat "created:  "
                                             (format-time-string 
                                              default-date-format))))))
(global-set-key "\C-cz" (function (lambda () (interactive)
                                    (region-command-on-word 'fix-camel))))
(global-set-key "\C-cv" 'view-file)
(global-set-key "\C-cx" 'kill-bottom-buffer-and-window)
(global-set-key "\C-cm" 'apply-macro-to-region-lines)
(global-set-key "\C-cc" 'caps-lock-mode)
(global-set-key "\C-cb" 'bury-buffer)
(global-set-key [?\s-s] 'ispell-buffer)
(global-set-key "\C-cf" 'insert-ifdef)
(global-set-key "\C-cs" 'sort-lines)
(global-set-key "\C-c?" 'show-file-name)
(global-set-key [up] 'go-up)
(global-set-key [down] 'go-down)

; this is quieter than global-unset-key:
(mapcar (function (lambda (key) (global-set-key key 'ignore)))
        '([insert] [home] [end] [left] [right]
          [f1] [f2] [f3] [f4] [f5] [f6] [f7] [f8] [f9] [f10] [f11] [f12]))

;; Setting various variables:

(setq true                              t
      false                             nil
      mode-line-format                  default-mode-line-format
      keep-old-versions                 15
      keep-new-versions                 15
      display-time-string-forms         '(24-hours ":" minutes)
      max-lisp-eval-depth               10000
      line-number-mode                  t
      auto-save-timeout                 30
      require-final-newline             t
      search-highlight                  t
      compilation-window-height         20
      compilation-ask-about-save        nil
      compilation-scroll-output         t
      eval-expression-print-length      1024
      inhibit-startup-message           t
      enable-local-eval                 t
      global-auto-revert-mode           t
      Buffer-menu-buffer+size-width     45
      visible-bell                      t
      version-control                   t
      save-place-file                   "~/.places.sav"
      apropos-do-all                    t
      next-screen-context-lines         0
      scroll-step                       1
      next-line-add-newlines            nil
      file-name-handler-alist           nil ;get rid of ange-ftp
      default-major-mode                'text-mode
      initial-major-mode                'text-mode
      ediff-window-setup-function       'ediff-setup-windows-plain
      user-mail-address                 "hioreanu@gmail.com"
      delete-old-versions               t
      display-messages-buffer           t
      mouse-yank-at-point               t
      tags-revert-without-query         t
      initial-scratch-message           nil
      repeat-on-final-keystroke         t
      colon-double-space                t
      gnus-select-method                '(nntp "uchinews")
      align-indent-before-aligning      t
      spook-phrases-file                "~/spook.lines"
      smooth-scroll-margin              3
      widget-mouse-face                 'default
      gc-cons-threshold                 10000000
      show-paren-style                  'parenthesis
      mouse-wheel-scroll-amount         '(1 ((shift) . 5) ((control) . nil))
      mwheel-scrool                     '(1 . 5)
      org-log-done                      t
      org-startup-folded                'showall)

(setq load-path (cons "~/src/emacs-packages" load-path))
(setq backup-disable-regexp  
      "^/tmp/\\|^/home/ach/Mail\\|\\.places\\|\\.saves\\|\\.news")

(setq backup-enable-predicate
      '(lambda (name)
         (if (null (string-match backup-disable-regexp name))
             t
           nil)))

(defun set-backup-dir (dir)
  (and (file-exists-p dir)
       ; for older emacs versions
       (defun make-backup-file-name (file)
         (let ((backup (subst-char-in-string ?/ ?! (expand-file-name file)))
               (directory (expand-file-name (concat dir "/"))))
           (concat directory backup "~")))
       ; for emacs21 and above
       (setq backup-directory-alist (list (cons "." dir)))))
(set-backup-dir "~/.backups")

(setq system-identification
      (substring (system-name) 0
                 (string-match "\\..+" (system-name))))

(setq default-mode-line-format
      (list ""
            'mode-line-modified
;            "<"
;            (user-login-name)
;            "@"
;            'system-identification
;            ">"
            " %14b"
            " "
;            'display-time-string
;            " "
            "L%3l "
            "C%2c "
            '(-3 . "%P")
            " "
            "%[("
            'mode-name
            'minor-mode-alist
            "%n"
            'mode-line-process
            ")%]"
            "-%-"))

(defun axh-js-mode ()
  (cond ((fboundp 'js2-mode) (js2-mode))
        ((fboundp 'javascript-mode) (javascript-mode))
        (t (java-mode))))

(setq auto-mode-alist
  (append '(("\\.CC$"  . c++-mode)
            ("\\.C$"   . c++-mode)
            ("\\.cc$"  . c++-mode)
            ("\\.cpp$" . c++-mode)
            ("\\.cxx$" . c++-mode)
            ("\\.hpp$" . c++-mode)
            ("\\.hxx$" . c++-mode)
            ("\\.hh$"  . c++-mode)
            ("\\.c$"   . c-mode)
            ("\\.h$"   . c-mode)
            ("\\.x$"   . c-mode)        ; rpcgen
            ("\\.js$"  . axh-js-mode)
            ("\\.m$"   . objc-mode) 
            ("\\.ml$"  . sml-mode)
            ("\\.cgi$" . perl-mode)
            ("\\.pro$" . prolog-mode)
            ("\\.py$"  . python-mode)
            ("\\.tex$" . latex-mode))   ; rather than regular TeX mode
          auto-mode-alist))

(setq-default transient-mark-mode       nil
              tab-width                 4
              ; case-fold-search          nil
              indent-tabs-mode          nil
              ediff-auto-refine-limit   250000
              save-place                t)

(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'set-goal-column 'disabled nil)

;; (ensure you call emacs with "-bg black" or these looks bad)
;; (also, you can set it in Xdefaults, ie "emacs.background: black")

;(set-face-background 'modeline "darkgreen")
;(set-face-foreground 'modeline "darkgray")
;(set-face-background 'region   "darkgray")
;(set-face-foreground 'region   "lightgray")
;(set-face-background 'default  "black")
;(set-face-foreground 'default  "darkgray")
;(custom-set-faces)
;(custom-set-faces 'show-paren-mismatch-face
;                  '((((class color)) (:background "black" 
;                                      :foreground "red"))
;                    (t (:background "gray"))))
(if (in-path-p "xblink")
    (defun flash-screen ()
      (call-process "xblink" nil nil nil))
  (defun flash-screen ()
    (call-process "xrefresh" nil nil nil "-solid" (face-foreground 'default))))
(if (eq window-system 'x) (setq ring-bell-function 'flash-screen))

;; Various functions, modes, etc.:

(defun enable-ido ()
  (progn
    (and
     (file-readable-p "~/.emacs.d/local-disk")
     (setq ido-save-directory-list-file "~/.emacs.d/local-disk/ido.last"))
    (require 'ido)
    (ido-mode)))
  
; statements to be run, ignoring errors:
(setq init-stuff
      '((show-paren-mode t)
        (display-time)
        (defun mouse-avoidance-banish-destination ()
          (cons (1- (frame-width)) (1- (frame-height))))
;        (mouse-avoidance-mode 'banish)
        (resize-minibuffer-mode 1)
        (column-number-mode 1)
        (scroll-bar-mode -1)
        (menu-bar-mode 0)
        (tool-bar-mode nil)
        (blink-cursor-mode nil) ; emacs 22
        (font-lock-mode 0)
        (iswitchb-default-keybindings)
        (require 'auto-show)
        (require 'sml-site)
        (mouse-avoidance-set-pointer-shape x-pointer-left-ptr)
        (toggle-uniquify-buffer-names)
        (enable-ido)
        (require 'saveplace)
        (require 'color-theme)))

(defmacro error-encapsulate (arg)
  `(condition-case err
       ,arg
     (error "%s: %s" ',arg (cdr err))))

(map-macro 'error-encapsulate init-stuff)

(if (not display-messages-buffer)
    (progn (setq message-log-max nil)
           (kill-buffer "*Messages*")))
(setq axh-emacs-ver (number-to-string emacs-major-version))
(setq custom-file
      (concat "~/.emacs.d/custom-" axh-emacs-ver ".el"))
(mapcar (lambda (file) (and (file-exists-p file) (load-file file)))
        (list
         "~/src/my-info-bookmark.el"
         "~/src/my-mutt-mode.el"
         "~/src/caps-lock.el"
         "~/src/emacs-packages/python-mode.el"
         "~/src/emacs-packages/html-helper-mode.el"
         "~/vm.elc"
         "~/src/align.el"
         "~/.emacs.d/smooth-scrolling.el"
         "~/.emacs.d/js2-20080616.elc"
         "~/.emacs.d/highlight-80+.el"
         "~/.emacs.d/multi-term.el"
         (concat "~/.emacs.d/emacs" axh-emacs-ver "-256color-hack.el")))
(load custom-file)

; really bad terminal emulators emulate only vt100 or vt220, and poorly
(if (and (not window-system) 
         (not (null (string-match "vt100\\|vt220" (getenv "TERM")))))
    (fix-keys))
(if (eq window-system 'x) (global-set-key "\C-x\C-z" 'ignore))

;; Major mode hooks and customizations:

(defun write-exec-hook ()
  "see if the file is a script and make it executable if it is."
  (save-excursion
    (goto-char (point-min))
    (if (looking-at "#!")
        (set-file-modes buffer-file-name
                        (logior (file-modes buffer-file-name) 73))))
  nil)
(defun write-update-date-hook ()
  "Update the date at the top of the file after \"updated:\".
If the string \"updated:  \" is found on the first or second line of the file,
the text following it will be replaced with the current date.  If you
do not want this behaviour, set the buffer-local variable \"update-date\"
to nil, ie by inserting
/* Local Variables: */
/* update-date:nil */
/* End: */
at the end of your file."
  (if update-date
      (save-excursion
        (goto-char (point-min))
        (forward-line 1)
        (end-of-line)
        (and (search-backward "updated:  " (point-min) t)
             (kill-line)
             (null (delete-horizontal-space))
             (insert-right-justified 
              (concat "updated:  " 
                      (format-time-string default-date-format))))))
  nil)
(make-variable-buffer-local 'update-date)
(defvar update-date t
  "If non-nil, run \"write-update-date-hook\" when saving buffer.")
(setq-default update-date t)
(add-hook 'write-file-hooks 'write-update-date-hook) 
(add-hook 'after-save-hook 'write-exec-hook)

(defun axh-c-newline ()
  (interactive)
  (if (and (or (eq (caar (c-guess-basic-syntax)) 'c)
               (eq (caar (c-guess-basic-syntax)) 'comment-intro))
           (null (string-match "//" (thing-at-point 'line)))
           (null (string-match "\\*/[ \t]*\n" (thing-at-point 'line))))
      (progn (newline-and-indent) (insert "* "))
    (newline-and-indent)))
(defun axh-c-slash ()
  (interactive)
  (if (and (eq (caar (c-guess-basic-syntax)) 'c)
           (string-match "\\* \n" (thing-at-point 'line)))
      (progn
        (backward-char 1)
        (delete-char 1)
        (insert "/")
        (newline-and-indent))
    (insert "/")))
(defun check-for-non-whitespace-next-line ()
  (save-excursion
    (forward-line 1)
    (skip-chars-forward " \t")
    (if (eolp)
        nil
      'stop)))
(defun axh-c-stuff ()
  (c-set-style "k&r")
  (setq c-basic-offset                  2
;        c-comment-continuation-stars    "* "
;        c-block-comment-prefix          "* "
        c-electric-pound-behavior       '(alignleft)
        c-progress-interval             2
        c-macro-shrink-window-flag      t
        c-macro-prompt-flag             t
        c-hanging-comment-ender-p       nil
        c-hanging-comment-starter-p     nil        
        tab-width                       4
        indent-tabs-mode                nil
        c-tab-always-indent             t
        case-fold-search                nil)
   (setq c-hanging-braces-alist
         (list '(brace-list-open)
               '(brace-entry-open)
               '(substatement-open after)
               '(block-close . c-snug-do-while)
               '(extern-lang-open after)
               '(inexpr-class-open after)
               '(inexpr-class-close before)
               '(class-open after)
               '(class-close before)))
  (setq c-cleanup-list (list 'scope-operator 'brace-else-brace
                             'brace-elseif-brace 'empty-defun-braces))
  (setq c-hanging-semi&comma-criteria 
        (cons 'check-for-non-whitespace-next-line c-hanging-semi&comma-criteria))
  (modify-syntax-entry ?_ "w")
  (c-set-offset 'case-label '+)
  (c-set-offset 'brace-list-open '+)
  (set (make-local-variable 'dabbrev-case-fold-search) nil)
  (set (make-local-variable 'dabbrev-case-replace) nil)
  (define-key c-mode-base-map "\C-m" 'axh-c-newline)
  (define-key c-mode-base-map "/" 'axh-c-slash)
  (setq c-C++-protection-kwds "private\\|protected\\|public\\|signals\\|slots")
  (c-toggle-auto-hungry-state 1))
; FIXME: disabled for now, need to integrate with google conventions
; (add-hook 'c-mode-common-hook 'axh-c-stuff)
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq sentence-end-double-space t)
            (setq parens-require-spaces nil)
            (setq fill-column 79)))

; FIXME:  asm-mode really sucks, need to rewrite it someday
(defun axh-asm-newline ()
  (interactive)
  (delete-horizontal-space)
  (asm-newline)
  (beginning-of-line)
  (delete-horizontal-space)
  (tab-to-tab-stop))
(defun axh-asm-indent ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (looking-at " ")
        (delete-horizontal-space)
      (insert "    "))))
(defun axh-asm-space ()
  (interactive)
  (if (eq (string-match "^    [^ \t]*$" (thing-at-point 'line)) 0)
      (tab-to-tab-stop)
    (insert " ")))
(defun axh-asm-hook ()
  (setq tab-stop-list '(4 12 32))
  (define-key asm-mode-map " " 'axh-asm-space)
  (define-key asm-mode-map "\C-j" 'newline)
  (define-key asm-mode-map "\C-i" 'axh-asm-indent)
  (define-key asm-mode-map [backspace] 'hungry-backspace)
  (define-key asm-mode-map "\C-m" 'axh-asm-newline))
(add-hook 'asm-mode-hook 'axh-asm-hook)

(defun axh-textmode-stuff ()
  (setq fill-column 75)
  (setq sentence-end-double-space t))
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'axh-textmode-stuff)

(defun axh-info-stuff ()
    (set-face-foreground 'info-xref "blue")
    (set-face-background 'info-xref "black")
    (set-face-foreground 'info-node "red")
    (set-face-background 'info-node "black")
    (setq automatic-footnotes "On")
;    (local-set-key "j" 'go-down)
;    (local-set-key "k" 'go-up)
)
(add-hook 'Info-mode-hook 'axh-info-stuff)

(defun axh-view-mode-hook ()
  (local-set-key "j" 'go-down)
  (local-set-key "k" 'go-up))
; FIXME: disabled pending fix
;(add-hook 'view-mode-hook 'axh-view-mode-hook)

(defun axh-mutt-mode-hook ()
  (fix-keys)
  (flyspell-mode 1))
(add-hook 'mutt-mode-hook 'axh-mutt-mode-hook)

;; NB:  I needed to comment out some (message "foo") thingy somewhere
;; in save-place.el in order to have this display....
(defun axh-lisp-mode-hook ()
  (eldoc-mode t)
  (message nil))
(add-hook 'lisp-interaction-mode-hook 'axh-lisp-mode-hook t)

(add-hook 'emacs-lisp-mode-hook 'axh-lisp-mode-hook t)

;; NT-specific stuff:

(defun do-nt-stuff ()
  (set-default-font "-*-Fixedsys-normal-r-*-*-12-90-96-96-c-*-iso8859-1")
  (set-frame-position (selected-frame) 0 0)
  (setq inhibit-startup-echo-area-message "Administrator")
  (setq inhibit-startup-echo-area-message "hioreanu")
  (load "comint")
  (fset 'original-comint-exec-1 (symbol-function 'comint-exec-1))
  (defun comint-exec-1 (name buffer command switches)
    (let ((binary-process-input t)
          (binary-process-output nil))
      (original-comint-exec-1 name buffer command switches)))
  (mapcar (lambda (x) (and (file-exists-p x)
                           (setq explicit-shell-file-name x)))
          '("c:/cygwin/bin/bash" "c:/cygnus/CYGWIN~1/H-I586~1/bin/bash"))
  (setq compile-command "NMAKE")
  (let ((windir (if (file-exists-p "/WINNT") "/WINNT" "/WINDOWS")))
    (setq exec-path (append
                     (list "/cygwin/bin"
                           "/cygwin/usr/bin"
                           "/cygwin/sbin"
                           "/cygwin/usr/sbin"
                           windir
                           (concat windir "/system32")
                           (concat windir "/system")
                           (concat windir "/command")
                           "/PROGRA~1/MICROS~1/COMMON/MSDEV98/BIN"
                           "/PROGRA~1/MICROS~1/VC98/BIN"
                           (concat "/PROGRA~1/MICROS~1/COMMON/TOOLS"
                                   (if (file-exists-p "/ntldr")
                                       "WINNT"
                                     "WIN95"))
                           "/PROGRA~1/MICROS~1/COMMON/TOOLS")
                     exec-path)))
  (setq vc-handle-cvs nil)              ; VC is broken under windows
  (setenv "MSDevDir" "C:\\PROGRA~1\\MICROS~1\\COMMON\\msdev98")
  (setenv "MSVCDir" "C:\\PROGRA~1\\MICROS~1\\VC98")
  (setenv "LIB" (concat "C:\\PROGRA~1\\MICROS~1\\VC98\\LIB;"
                        "C:\\PROGRA~1\\MICROS~1\\VC98\\LIB\\MFC\\LIB;"
                        (getenv "LIB")))
  (setenv "INCLUDE" (concat
                     "C:\\PROGRA~1\\MICROS~1\\VC98\\ATL\\INCLUDE"
                     "C:\\PROGRA~1\\MICROS~1\\VC98\\INCLUDE"
                     "C:\\PROGRA~1\\MICROS~1\\VC98\\MFC\\INCLUDE"
                     (getenv "INCLUDE")))
  (message "NT-setup"))

;; Home-machine-specific stuff:

(defun do-home-stuff ()
  (require 'edebug)
  (autoload 'vm "vm" "Start VM on your primary inbox." t)
  (autoload 'vm-mode "vm" "Run VM major mode on a buffer" t)
  (autoload 'vm-mail "vm" "Send a mail message using VM." t)
  (autoload 'vm-visit-folder "vm" "Start VM on an arbitrary folder." t)
  (autoload 'vm-visit-virtual-folder "vm" "Visit a VM virtual folder." t)
  (setq vm-init-file "~/Mail/init-file")
  (setq inhibit-startup-echo-area-message "ach")
  (message "Home Machine"))

;; Stuff for other machines:

(defun do-other-machine-stuff ()
  ; these setq's HAVE to appear like this, one per line:
  (setq inhibit-startup-echo-area-message "ahiorean")
  (setq inhibit-startup-echo-area-message "ach")
  (setq inhibit-startup-echo-area-message "hioreanu")
  (setq inhibit-startup-echo-area-message "root")
  (message "Generic setup"))

;; Execute machine-specific stuff:

(cond ((string-match "VMWARE\\|C6N0L6" system-identification) 
       (do-nt-stuff))
      ((string-match "greenscreen" system-identification)
       (do-home-stuff))
      (t (do-other-machine-stuff)))

(if (fboundp 'w32-drag-n-drop)
    (let ((windir (if (file-exists-p "/WINNT") "/WINNT" "/WINDOWS")))
      (setenv "PATH" (concat "/cygwin/bin:"
                             "/cygwin/usr/bin:"
                             "/cygwin/sbin:"
                             "/cygwin/usr/sbin/:"
                             (getenv "PATH") ":"
                             windir ":"
                             windir "/system32:"
                             windir "/system:"
                             windir "/command:"
                             "/PROGRA~1/MICROS~1/COMMON/MSDEV98/BIN:"
                             "/PROGRA~1/MICROS~1/VC98/BIN:"
                             "/PROGRA~1/MICROS~1/COMMON/TOOLS/"
                             (if (file-exists-p "/ntldr")
                                 "WINNT:"
                               "WIN95:")
                             "/PROGRA~1/MICROS~1/COMMON/TOOLS"))
      (setenv "MSDevDir" "C:\\PROGRA~1\\MICROS~1\\COMMON\\msdev98")
      (setenv "MSVCDir" "C:\\PROGRA~1\\MICROS~1\\VC98")
      (setenv "LIB" (concat "C:\\PROGRA~1\\MICROS~1\\VC98\\LIB;"
                            "C:\\PROGRA~1\\MICROS~1\\VC98\\LIB\\MFC\\LIB;"
                            (getenv "LIB")))
      (setenv "INCLUDE" (concat
                         "C:\\PROGRA~1\\MICROS~1\\VC98\\ATL\\INCLUDE"
                         "C:\\PROGRA~1\\MICROS~1\\VC98\\INCLUDE"
                         "C:\\PROGRA~1\\MICROS~1\\VC98\\MFC\\INCLUDE"
                         (getenv "INCLUDE")))))

(when (eq emacs-major-version 21)
  (blink-cursor-mode -1)
  (setq mail-specify-envelope-from t)
  (mouse-wheel-mode)
  (setq show-trailing-whitespace 1)
  (tool-bar-mode -1))

(when (string-match "Aquamacs" (emacs-version))
  (setq ns-command-modifier 'meta
        ns-alternate-modifier nil
        ns-use-mac-modifier-symbols nil)
  (tool-bar-mode -1)
  (tabbar-mode 1)
  (cua-mode nil)
  (aquamacs-autoface-mode -1)
  (setq-default cursor-type 'box))

(and (file-readable-p (concat (getenv "HOME") "/.emacs-local"))
     (load-file (concat (getenv "HOME") "/.emacs-local")))

(message "Finished!")

;; Start with a nice clean environment:

(garbage-collect)

;TODO: fix the minibuffer so that it doesn't display the name of the
;current buffer when switching buffers, make a tdf minor mode, gzip-mode
; completion-ignored-extensions
; delete-if-not (instead of 'filter')

; M-C-o split-line
; M-^ delete-indentation
; M-r move-to-window-line
; M-m back-to-indentation
; M-$ ispell-word
; C-x - shrink-window-if-larger-than-buffer
; C-x M-: repeat-complex-command
; C-x r k kill-rectangle
; C-M-/ debbrev-completion
; M-/ dabbrev-expand
(custom-set-variables
 '(load-home-init-file t t)
 '(toolbar-visible-p nil))
