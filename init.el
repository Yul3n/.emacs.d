;;; init.el --- My configuration
;;; Commentary:

;; -*- lexical-binding: t; -*-

;;; Code:
;; Disable garbage collection to improve startup time
(setq gc-cons-threshold most-positive-fixnum ; 2^61 bytes
      gc-cons-percentage 0.6)
 
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold 16777216 ; 16mb
          gc-cons-percentage 0.1)))

;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; Aesthetic changes
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-nord t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package mood-line
  :config
  (mood-line-mode))
  
(use-package display-line-numbers
  :straight (:type built-in)
  :hook
  (prog-mode . display-line-numbers-mode))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook))

; I like the scientifica font
(set-frame-font
 "-HBnP-scientifica-normal-normal-normal-*-11-*-*-*-*-0-iso10646-1")

;; Disable unuseful UI elements
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

(use-package evil-leader
  :config
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
   "<SPC>" 'projectile-find-file
   "sb"    'swiper
   "ff"    'find-file
   "fr"    'counsel-recentf)
  (global-evil-leader-mode))

(use-package undo-tree
  :config
  (global-undo-tree-mode))

(use-package evil
  :config
  (evil-mode 1))

(use-package ivy
  :config
  (ivy-mode 1)
  :custom
  (ivy-height 14))

(use-package counsel
  :config
  (counsel-mode 1))

(use-package projectile
  :commands project-find-file
  :config
  (setq projectile-completion-system 'ivy))

(electric-pair-mode 1)

;; Set up indentation
(use-package smart-tabs-mode
  :config
  (smart-tabs-insinuate 'c))

(setq-default indent-tabs-mode t
	      tab-width 8
	      electric-indent-inhibit t)
(defvaralias 'c-basic-offset 'tab-width)
(setq backward-delete-char-untabify-method 'hungry)

;; Display a Pipe in tabs
(setq whitespace-display-mappings
  '((tab-mark 9 [124 9] [92 9])))
(add-hook 'c-mode-hook 'whitespace-mode)

;; Customize faces for whitespace mode
(custom-set-faces
 '(whitespace-indentation ((t (:background "#"))))
 '(whitespace-space-after-tab ((t nil))))

(custom-set-variables
 '(whitespace-line-column 100))

;; Set up code completion and checking, for C
(setq company-idle-delay 0.1
      company-minimum-prefix-length 1)
(use-package irony
  :hook
  (c-mode     . irony-mode)
  (irony-mode . irony-cdb-autosetup-compile-options))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package flycheck-irony)

(use-package company
  :hook (prog-mode . company-mode)
  :bind
  ("M-j" . 'company-select-next)
  ("M-k" . 'company-select-previous))

(use-package company-irony)

(use-package company-irony-c-headers)

(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

(eval-after-load 'company
  '(add-to-list 'company-backends '(company-irony-c-headers company-irony)))

;; Set up code completion and checking, for Ocaml
(use-package tuareg
  :custom
  (tuareg-match-patterns-aligned t)
  (tuareg-prettify-symbols-full  t))

;; Set up Merlin
(let ((opam-share (ignore-errors (car (process-lines "opam" "config" "var" "share")))))
 (when (and opam-share (file-directory-p opam-share))
  (add-to-list 'load-path (expand-file-name "emacs/site-lisp" opam-share))
  (autoload 'merlin-mode "merlin" nil t nil)
  (add-hook 'tuareg-mode-hook 'merlin-mode t)
  (add-hook 'caml-mode-hook 'merlin-mode t)))

(with-eval-after-load 'company
 (add-to-list 'company-backends 'merlin-company-backend))

(add-hook 'merlin-mode-hook 'company-mode)

;; Email, you have to set up the email yourself
(use-package mu4e
  :commands mu4e
  :custom
  (mu4e-maildir           "~/.mail")
  (mu4e-sent-folder       "/INBOX.OUTBOX")
  (mu4e-drafts-folder     "/INBOX.DRAFT")
  (mu4e-trash-folder      "/INBOX.TRASH")
  (mu4e-refile-folder     "/INBOX")
  (mu4e-html2text-command "html2text"))

;; git
(use-package magit)

(use-package git-gutter-fringe)

(setq-default fringes-outside-margins t)
;; thin fringe bitmaps
(define-fringe-bitmap 'git-gutter-fr:added [224]
  nil nil '(center repeated))
(define-fringe-bitmap 'git-gutter-fr:modified [224]
  nil nil '(center repeated))
(define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240]
  nil nil 'bottom)

(add-hook 'prog-mode-hook 'git-gutter-mode)


;;; init.el ends here
