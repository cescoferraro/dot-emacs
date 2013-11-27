; --------------------------------------------------------------------------------
; Combined Emacs init-file for linux and mac
; Used with Swedish keyboard layout
; --------------------------------------------------------------------------------

; Load customizations from subdir
(add-to-list 'load-path "~/.emacs.d/")

; Use Melpa for extra packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

(package-initialize)

; Custom themes folder
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'my-dev-1 t)

; --------------------------------------------------------------------------------
; Customizations for GUI emacs, ie GTK or Cocoa
; --------------------------------------------------------------------------------

(if window-system
    (progn
      ;; Save / Restore window-sizes
      (load-library "restore-framegeometry")
      (add-hook 'after-init-hook 'load-framegeometry)
      (add-hook 'kill-emacs-hook 'save-framegeometry)

      ;; For linux, font and background color:
      (if (string-equal (window-system) "x")  ; x = linux, ns = cocoa
          (progn
            (set-default-font "Monospace 8" ) ; Linux
            (set-background-color "#ffffff"))

        (progn
          (set-default-font "Menlo-Regular 12")) ; Mac
        )

      ;; Hide menubar (icons) and scrollbar - thanks to https://sites.google.com/site/steveyegge2/effective-emacs
      (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
      (if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

      ;; Set title bar to show file name if available, else buffer name
      (setq frame-title-format '(buffer-file-name "%f" ("%b")))

      ;; Disable C-z, use window-system to minimize window
      (global-set-key "\C-z" (lambda () (interactive) (message "Zzzzzz...")))
      )
  )


; --------------------------------------------------------------------------------
; Load custom functions + keyboard shortcuts
; --------------------------------------------------------------------------------

; Swap content between two windows
(load-library "swap-windows")
(global-set-key (kbd "\C-x 6") 'swap-windows)

; Toggle vertical/horizontal split of two windows
(load-library "rotate-frame-split")
(global-set-key (kbd "\C-x 5") 'rotate-frame-split)

; Save copy of buffer without switching to the new buffer/file name
(load-library "save-copy-as")
(global-set-key "\C-c\C-w" 'save-copy-as)

; dabbrev-expand via C-TAB
; TODO: This doesn't work in a terminal
(global-set-key (kbd "C-<tab>") 'dabbrev-expand)
(define-key minibuffer-local-map (kbd "C-<tab>") 'dabbrev-expand)

;; Go to previous window, anti-clockwise (opposite of C-x o)
(global-set-key (kbd "\C-x p") '(lambda () (interactive) (other-window -1)))

;; Kill buffer in other (next) window, ie for closing a man-page etc
(load-library "kill-buffer-other-window")
(global-set-key (kbd "\C-x 4 k") 'kill-buffer-other-window)

;; Vertical split by default
(setq split-height-threshold nil)
(setq split-width-treshold 0)


; --------------------------------------------------------------------------------
; Other keyboard fixes and shortcuts
; --------------------------------------------------------------------------------

; backspace/C-h fix:
(global-set-key "\C-h" 'backward-delete-char)
(normal-erase-is-backspace-mode 0)

; Help key:
(global-set-key (kbd "C-+") 'help)

; Mac, Swedish keyboard: Leave right alt-key alone, else I cannot write \
; Solution found at the bottom of this page (French keyboard): http://stackoverflow.com/questions/6344389/osx-emacs-unbind-just-the-right-alt
(setq-default mac-option-modifier nil)


; --------------------------------------------------------------------------------
; Options mainly for programming
; --------------------------------------------------------------------------------

; C-mode
(setq c-default-style "linux"
      c-basic-offset 4)

; Indent with spaces, not tabs
(setq-default indent-tabs-mode nil)

; http://www.gnu.org/software/emacs/manual/html_node/emacs/Hungry-Delete.html
(setq c-toggle-hungry-state t)

; Always delete trailing whitespace when saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)

; Delete trailing whitespace only in C-mode
;(add-hook 'c-mode-common-hook (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

; (Un-)Comment key bindings
; TODO: Improve to custom 'comment-region-or-line, this doesn't quite work ie for perl-mode:
(global-set-key "\C-cc" 'comment-region)
(global-set-key "\C-cu" 'uncomment-region)

;; rainbow-delimiters for lisp-modes
(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)

;; Auto indent all prog-modes
(add-hook 'prog-mode-hook '(lambda ()
                             (local-set-key (kbd "RET") 'reindent-then-newline-and-indent)))

;; Smarter tab (completion, indent-region, indent)
(add-hook 'prog-mode-hook 'smart-tab-mode)

;; Smartparens: Auto match/complete ([{" etc
(require 'smartparens-config)
(add-hook 'prog-mode-hook 'smartparens-mode)

;; Show matching brace/parens for prog-modes
(add-hook 'prog-mode-hook 'show-paren-mode)

;; PHP Eldoc
(add-hook 'php-mode-hook 'php-eldoc-enable)
(add-hook 'web-mode-hook 'php-eldoc-enable)

;; web-mode (http://web-mode.org)
(add-to-list 'auto-mode-alist '("\\.phpclass'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(defun my-web-mode-hook ()
  "My settings for Web mode."
  ;; indents = 4 spaces
  (setq web-mode-markup-indent-offset 3)
  (setq web-mode-css-indent-offset 3)
  (setq web-mode-code-indent-offset 3)

  ;; Get colors from active theme
  (set-face-attribute 'web-mode-html-tag-face nil :foreground
                      (face-attribute 'font-lock-function-name-face :foreground))
  (set-face-attribute 'web-mode-html-attr-name-face nil :foreground
                      (face-attribute 'font-lock-type-face :foreground))
  (set-face-attribute 'web-mode-html-attr-value-face nil :foreground
                      (face-attribute 'font-lock-string-face :foreground))
  )
(add-hook 'web-mode-hook  'my-web-mode-hook)

; --------------------------------------------------------------------------------
; Extra modes
; --------------------------------------------------------------------------------

; Lua-mode:
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))


; --------------------------------------------------------------------------------
; Various file options
; --------------------------------------------------------------------------------

; Preserve backup-file user/group, especially important under sudo / su
(setq backup-by-copying-when-mismatch t)

; Always end files with a newline
(setq require-final-newline 't)


; --------------------------------------------------------------------------------
; Various other options
; --------------------------------------------------------------------------------

; Disable all Version Control backends. Quicker start-up. Avoid hanging in git-enabled dirs with emacs-gtk on Linux
(setq vc-handled-backends ())

; No welcome message
(setq inhibit-startup-message t)


; --------------------------------------------------------------------------------