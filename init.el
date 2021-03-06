;; Make startup faster by reducing the frequency of garbage
;; collection.  The default is 800 kilobytes.  Measured in bytes.
;; increase threshold
(setq gc-cons-threshold most-positive-fixnum)

;; don't show startup screen
(setq-default inhibit-startup-message t)

;; disable toolbar and scrollbar
;; these are minor modes so they take -1 and not nil
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; jit settings
;; idk really about this, got this from a blogpost
(setq jit-lock-stealth-time nil)
(setq jit-lock-defer-time nil)
(setq jit-lock-defer-time 0.05)
(setq jit-lock-stealth-load 200)

;; never use tabs (only spaces)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq c-basic-offset 4)
    
;; show matching parenthesis
(show-paren-mode 1)

;; hightlight current line
(global-hl-line-mode t)
;; display line numbers globally
(global-display-line-numbers-mode 1)
;; disable line numbers in some modes
(dolist (modes '(org-mode-hook
                 term-mode-hook
                 shell-mode-hook
                 eshell-mode-hook))
  (add-hook modes (lambda () (display-line-numbers-mode 0))))

;; enable visual bell
(setq-default visual-bell t)

;; these functions will be executed after emacs init completes
(add-hook 'emacs-startup-hook
	  ;; show startup time
	  ;; Use a hook so the message doesn't get clobbered by other messages.
          (lambda ()
	        (message "Emacs ready in %s with %d garbage collections."
		             (format "%.4f seconds" (float-time
					                         (time-subtract after-init-time before-init-time)))
                     gcs-done))
	      ;; Make gc pauses faster by decreasing the threshold.
	      (setq gc-cons-threshold (expt 2 23)))


;; initialize package sources
(require 'package)

;; set repos
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu/org/packages/")))

;; initialize package manager
(package-initialize)

;; keep refreshing until unless we have updated contents
(unless package-archive-contents
  (package-refresh-contents))

;; initialize use-package for non-linux platforms
;; this will use default package manager to install this package
;; and will keep trying until unless it gets installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; after this step, we require use-package package
(require 'use-package)
;; this ensures taht packages are installed if they are not present
(setq use-package-always-ensure t)

;; set a different file to store customizations
;; emacs sometimes adds customizations on it's own
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; load theme instantly
(use-package soothe-theme
  :defer nil ;; load this immidiately
  :init (load-theme 'soothe t)) ;; don't prompt and load immidiately

;; setup ivy for code completion
(use-package ivy
  :defer 2 ;; load this after 2 seconds of idle time
  :hook (after-init . ivy-mode) ;; enable ivy mode
  :config
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-ag)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (global-set-key (kbd "C-M-j") 'counsel-switch-buffer)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))

;; provide more ivy features
(use-package ivy-rich
  :defer 2
  :hook (after-mode . ivy-rich-mode))

;; make modeline feel better
(use-package doom-modeline
  :defer 2
  :hook (after-init . doom-modeline-mode))

;; be evil
(use-package evil
  :defer 2
  :hook (after-init . evil-mode))

;; make parenthesis look better
;; different colors for different level of parenthesis
(use-package rainbow-delimiters
  :defer t
  :hook (prog-mode . rainbow-delimiters-mode))

;; write a keybinding partially and emacs will show you
;; different options available to complete the binding
(use-package which-key
  :defer 2
  :config (setq which-key-idle-delay 1))

;; don't delete files immidiately
(setq trash-directory "~/.trash")
(setq delete-by-moving-to-trash t)

;; emacs creates backup files that end with a ~
;; we don't want to turn of backup as they are useful sometimes (in some very bad times)
;; Write backups to ~/.emacs.d/backup/
;; source : https://superuser.com/questions/236883/why-does-emacs-create-a-file-that-starts-with
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying      t  ; Don't de-link hard
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      5) ; and how many of the old

;; better help for emacs stuff
(use-package helpful
  :defer 3
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describle-function] . counsel-describe-function)
  ([remap describle-command] . helpful-command)
  ([remap describle-variable] . counsel-describe-variable)
  ([remap describle-key] . helpful-key)) 

;; use doom emacs themes
(use-package doom-themes)

;; help us expand macro and see what's actually going on under hood
(use-package macrostep
  :defer 2
  :config
  (define-key emacs-lisp-mode-map (kbd "C-c e") 'macrostep-expand))
;; The standard keybindings in macrostep-mode are the following:
;; [e, =, RET]  : expand the macro form following point one step
;; [c, u, DEL]  : collapse the form following point
;; [q, C-c C-c] : collapse all expanded forms and exit macrostep-mode
;; [n, TAB]     : jump to the next macro form in the expansion
;; [p, M-TAB]   : jump to the previous macro form in the expansion

;; we want icons everywhere
(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts ;; install fonts if not present
  :init
  ;; installs this font only if it is not found
  (unless (find-font (font-spec :name "all-the-icons"))
    (all-the-icons-install-fonts t)))

;; icons also in dired mode
(use-package all-the-icons-dired
  :if (display-graphic-p)
  :hook (dired-mode . all-the-icons-dired-mode))

;; general key bindings
;; (use-package general
;;   :defer t
;;   :hook (evil-mode . (general-evil-setup)))
