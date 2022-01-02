;;; init.el --- Emacs config.

;;; Commentary:

;;  Emacs Startup File.

;;; Code:
(require 'package)

;; Add melpa to your packages repositories
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; {{{ METALS PART

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
      use-package-always-ensure t
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Enable scala-mode for highlighting, indentation and motion commands
(use-package scala-mode
  :interpreter
    ("scala" . scala-mode))

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false"))
)

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  ;; Optional - enable lsp-mode automatically in scala files
  :hook  (scala-mode . lsp)
         (lsp-mode . lsp-lens-mode)
  :custom
	(lsp-headerline-breadcrumb-enable t)
  :config
  ;; Uncomment following section if you would like to tune lsp-mode performance according to
  ;; https://emacs-lsp.github.io/lsp-mode/page/performance/
        (setq gc-cons-threshold 100000000) ;; 100mb
        (setq read-process-output-max (* 1024 1024)) ;; 1mb
        (setq lsp-idle-delay 0.500)
        (setq lsp-log-io nil)
        (setq lsp-completion-provider :capf)
        (setq lsp-prefer-flymake nil)
	;; (setq lsp-enable-file-watchers nil)
	)

;; Add metals backend for lsp-mode
(use-package lsp-metals
  :config (setq lsp-metals-treeview-show-when-views-received nil))

;; Enable nice rendering of documentation on hover
(use-package lsp-ui
  :init (setq lsp-ui-doc-enable t
	      lsp-ui-doc-position 'top
	      lsp-ui-sideline-ignore-duplicate t
	      )
);;  :config (setq lsp-ui-doc-enable nil))

;; lsp-mode supports snippets, but in order for them to work you need to use yasnippet
;; If you don't want to use snippets set lsp-enable-snippet to nil in your lsp-mode settings
;;   to avoid odd behavior with snippets and indentation
(use-package yasnippet)

;; Add company-lsp backend for metals
;; (use-package company-lsp)
(use-package company
  :custom
  (company-tooltip-align-annotations t)
  (company-require-match nil)
  :config
  (global-company-mode 1))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  )
(use-package dap-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )

;; }}} END OF THE METALS PART




;; {{{ IVY PART https://github.com/rememberYou/.emacs.d/blob/master/config.org#ivy

(use-package counsel
  :after ivy
  :delight
  :bind (("C-x C-d" . counsel-dired-jump)
         ("C-x C-h" . counsel-minibuffer-history)
         ("C-x C-l" . counsel-find-library)
         ("C-x C-r" . counsel-recentf)
         ("C-x C-u" . counsel-unicode-char)
         ("C-x C-v" . counsel-set-variable))
  :config (counsel-mode)
  :custom (counsel-rg-base-command "/usr/local/bin/rg -S -M 150 --no-heading --line-number --color never %s"))

(use-package ivy
  :delight
  :after ivy-rich
  :bind (("C-x b" . ivy-switch-buffer)
         ("C-x B" . ivy-switch-buffer-other-window)
         ("M-H"   . ivy-resume)
         :map ivy-minibuffer-map
         ("<tab>" . ivy-alt-done)
         ("C-i" . ivy-partial-or-done)
         ("S-SPC" . nil)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-switch-buffer-kill))
  :custom
  (ivy-case-fold-search-default t)
  (ivy-count-format "(%d/%d) ")
  (ivy-re-builders-alist '((t . ivy--regex-plus)))
  (ivy-use-virtual-buffers t)
  :config (ivy-mode))

(use-package ivy-rich
  :defer 0.1
  :preface
  (defun ivy-rich-branch-candidate (candidate)
    "Displays the branch candidate of the candidate for ivy-rich."
    (let ((candidate (expand-file-name candidate ivy--directory)))
      (if (or (not (file-exists-p candidate)) (file-remote-p candidate))
          ""
        (format "%s%s"
                (propertize
                 (replace-regexp-in-string abbreviated-home-dir "~/"
                                           (file-name-directory
                                            (directory-file-name candidate)))
                 'face 'font-lock-doc-face)
                (propertize
                 (file-name-nondirectory
                  (directory-file-name candidate))
                 'face 'success)))))

  (defun ivy-rich-compiling (candidate)
    "Displays compiling buffers of the candidate for ivy-rich."
    (let* ((candidate (expand-file-name candidate ivy--directory)))
      (if (or (not (file-exists-p candidate)) (file-remote-p candidate)
              (not (magit-git-repo-p candidate)))
          ""
        (if (my/projectile-compilation-buffers candidate)
            "compiling"
          ""))))

  (defun ivy-rich-file-group (candidate)
    "Displays the file group of the candidate for ivy-rich"
    (let ((candidate (expand-file-name candidate ivy--directory)))
      (if (or (not (file-exists-p candidate)) (file-remote-p candidate))
          ""
        (let* ((group-id (file-attribute-group-id (file-attributes candidate)))
               (group-function (if (fboundp #'group-name) #'group-name #'identity))
               (group-name (funcall group-function group-id)))
          (format "%s" group-name)))))

  (defun ivy-rich-file-modes (candidate)
    "Displays the file mode of the candidate for ivy-rich."
    (let ((candidate (expand-file-name candidate ivy--directory)))
      (if (or (not (file-exists-p candidate)) (file-remote-p candidate))
          ""
        (format "%s" (file-attribute-modes (file-attributes candidate))))))

  (defun ivy-rich-file-size (candidate)
    "Displays the file size of the candidate for ivy-rich."
    (let ((candidate (expand-file-name candidate ivy--directory)))
      (if (or (not (file-exists-p candidate)) (file-remote-p candidate))
          ""
        (let ((size (file-attribute-size (file-attributes candidate))))
          (cond
           ((> size 1000000) (format "%.1fM " (/ size 1000000.0)))
           ((> size 1000) (format "%.1fk " (/ size 1000.0)))
           (t (format "%d " size)))))))

  (defun ivy-rich-file-user (candidate)
    "Displays the file user of the candidate for ivy-rich."
    (let ((candidate (expand-file-name candidate ivy--directory)))
      (if (or (not (file-exists-p candidate)) (file-remote-p candidate))
          ""
        (let* ((user-id (file-attribute-user-id (file-attributes candidate)))
               (user-name (user-login-name user-id)))
          (format "%s" user-name)))))

  (defun ivy-rich-switch-buffer-icon (candidate)
    "Returns an icon for the candidate out of `all-the-icons'."
    (with-current-buffer
        (get-buffer candidate)
      (let ((icon (all-the-icons-icon-for-mode major-mode :height 0.9)))
        (if (symbolp icon)
            (all-the-icons-icon-for-mode 'fundamental-mode :height 0.9)
          icon))))
  :config
  (plist-put ivy-rich-display-transformers-list
             'counsel-find-file
             '(:columns
               ((ivy-rich-candidate               (:width 73))
                (ivy-rich-file-user               (:width 8 :face font-lock-doc-face))
                (ivy-rich-file-group              (:width 4 :face font-lock-doc-face))
                (ivy-rich-file-modes              (:width 11 :face font-lock-doc-face))
                (ivy-rich-file-size               (:width 7 :face font-lock-doc-face))
                (ivy-rich-file-last-modified-time (:width 30 :face font-lock-doc-face)))))
  ;;(plist-put ivy-rich-display-transformers-list
  ;;           'counsel-projectile-switch-project
  ;;           '(:columns
  ;;             ((ivy-rich-branch-candidate        (:width 80))
  ;;              (ivy-rich-compiling))))
  (plist-put ivy-rich-display-transformers-list
             'ivy-switch-buffer
             '(:columns
               ((ivy-rich-switch-buffer-icon       (:width 2))
                (ivy-rich-candidate                (:width 40))
                (ivy-rich-switch-buffer-size       (:width 7))
                (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
                (ivy-rich-switch-buffer-major-mode (:width 20 :face warning)))
               :predicate (lambda (cand) (get-buffer cand))))
  (ivy-rich-mode 1))


(use-package all-the-icons-ivy
  :after (all-the-icons ivy)
  :custom (all-the-icons-ivy-buffer-commands '(ivy-switch-buffer-other-window))
  :config
  (add-to-list 'all-the-icons-ivy-file-commands 'counsel-dired-jump)
  (add-to-list 'all-the-icons-ivy-file-commands 'counsel-find-library)
  (all-the-icons-ivy-setup))

(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)
         :map swiper-map
         ("M-%" . swiper-query-replace)))

;; }}} THE END OF IVY PART

;; {{{ DOOM MODELINE
(use-package doom-modeline
  :ensure t
 :init (doom-modeline-mode 1))

(setq doom-modeline-height 20)
;; }}} END OF DOOM MODELINE

;; Disable mouse interface
(when window-system
  (scroll-bar-mode -1)            ; Disable the scroll bar
  (tool-bar-mode -1)              ; Disable the tool bar
  (tooltip-mode -1))              ; Disable the tooltips

;; {{{ Evil

;;(use-package evil
;;  :ensure t
;;  :config
;;  (evil-mode 1)
;;  (define-key evil-motion-state-map (kbd "RET") nil))
(unless (package-installed-p 'evil)
  (package-install 'evil))

(require 'evil)
(evil-mode 1)

;; Unmap RET
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "RET") nil))

;; }}} End of evil

;; {{{ Setup projectile

(unless (package-installed-p 'projectile)
  (package-install 'projectile))

(unless (package-installed-p 'counsel-projectile)
    (package-install 'counsel-projectile))

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)

(projectile-add-known-project "~/Projects/live-baccarat")
(projectile-add-known-project "~/Projects/baccarat-domain")
(projectile-add-known-project "~/Projects/coreservices")
(projectile-add-known-project "~/Projects/baccarat-dwh-events-producer")
(projectile-add-known-project "~/Projects/LAS-P-lightbend-akka-for-scala-professional-v1")
(projectile-add-known-project "~/Projects/cats-sandbox")
(projectile-add-known-project "~/Projects/common-features")
(projectile-add-known-project "~/Projects/rng-service-extras")
(projectile-add-known-project "~/Projects/loadtest")

;; }}} END OF Setup projectile

;; GIT GUTTER
(use-package git-gutter
  :ensure t
  :init
  (global-git-gutter-mode +1))

;; Close buffer without asking questions
  (global-set-key (kbd "C-x k") 'kill-current-buffer)

;; Disable bell
  (setq ring-bell-function 'ignore)

;; Setup autosave on disc
(auto-save-visited-mode t)

;; Highlight brackets
(show-paren-mode +1)

;; Setup autocompletion
(global-set-key (kbd "C-SPC") 'company-complete)
;; Setup formatting
(global-set-key (kbd "s-f") 'lsp-format-buffer)
;; Setup goto definition
(global-set-key (kbd "s-b") 'lsp-find-definition)
;; Setup peek find references
(global-set-key (kbd "s-r") 'lsp-ui-peek-find-references)
;; Toggle lsp breadcrumbs
;; (global-set-key (kbd "s-l t b") 'lsp-headerline-breadcrumb-mode)
;; Setup treemacs toggle key binding
(global-set-key (kbd "C-x C-t") 'treemacs)

;; Setup windmove
(windmove-default-keybindings)

;; Setup intend for js and json
(setq js-indent-level 2)


;; Setup folding
(use-package vimish-fold
  :ensure t
  :config (vimish-fold-global-mode t))

;; File to write custom-set-variables.
(setq custom-file "~/.emacs.d/custom.el")
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

;; Editorconfig
;; (use-package editorconfig
;;   :demand t
;;   :config
;;   (editorconfig-mode nil))

;; Toggle time and system load
(display-time-mode 1)

;; Update buffers according to file on disk
(global-auto-revert-mode t)

;; Font ligatures
(when (window-system)
  (set-frame-font "Fira Code")
  (set-face-attribute 'default nil :height 130)
  )
(let ((alist '((33 . ".\\(?:\\(?:==\\|!!\\)\\|[!=]\\)")
               (35 . ".\\(?:###\\|##\\|_(\\|[#(?[_{]\\)")
               (36 . ".\\(?:>\\)")
               (37 . ".\\(?:\\(?:%%\\)\\|%\\)")
               (38 . ".\\(?:\\(?:&&\\)\\|&\\)")
               (42 . ".\\(?:\\(?:\\*\\*/\\)\\|\\(?:\\*[*/]\\)\\|[*/>]\\)")
               (43 . ".\\(?:\\(?:\\+\\+\\)\\|[+>]\\)")
               (45 . ".\\(?:\\(?:-[>-]\\|<<\\|>>\\)\\|[<>}~-]\\)")
               (46 . ".\\(?:\\(?:\\.[.<]\\)\\|[.=-]\\)")
               (47 . ".\\(?:\\(?:\\*\\*\\|//\\|==\\)\\|[*/=>]\\)")
               (48 . ".\\(?:x[a-zA-Z]\\)")
               (58 . ".\\(?:::\\|[:=]\\)")
               (59 . ".\\(?:;;\\|;\\)")
               (60 . ".\\(?:\\(?:!--\\)\\|\\(?:~~\\|->\\|\\$>\\|\\*>\\|\\+>\\|--\\|<[<=-]\\|=[<=>]\\||>\\)\\|[*$+~/<=>|-]\\)")
               (61 . ".\\(?:\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\)\\|[<=>~]\\)")
               (62 . ".\\(?:\\(?:=>\\|>[=>-]\\)\\|[=>-]\\)")
               (63 . ".\\(?:\\(\\?\\?\\)\\|[:=?]\\)")
               (91 . ".\\(?:]\\)")
               (92 . ".\\(?:\\(?:\\\\\\\\\\)\\|\\\\\\)")
               (94 . ".\\(?:=\\)")
               (119 . ".\\(?:ww\\)")
               (123 . ".\\(?:-\\)")
               (124 . ".\\(?:\\(?:|[=|]\\)\\|[=>|]\\)")
               (126 . ".\\(?:~>\\|~~\\|[>=@~-]\\)")
               )
             ))
  (dolist (char-regexp alist)
    (set-char-table-range composition-function-table (car char-regexp)
                          `([,(cdr char-regexp) 0 font-shape-gstring]))))

(use-package vterm
  :load-path  "/Users/kharivitalij/Software/emacs-libvterm")

; Map escape to cancel (like C-g)...
(define-key isearch-mode-map [escape] 'isearch-abort)   ;; isearch
(define-key isearch-mode-map "\e" 'isearch-abort)   ;; \e seems to work better for terminals
(global-set-key [escape] 'keyboard-escape-quit)         ;; everywhere else

;; Setup smartparens
(unless (package-installed-p 'smartparens)
    (package-install 'smartparens))
(require 'smartparens-config)
(smartparens-global-mode 1)

(use-package base16-theme
 :demand
 :ensure t
 :config
 (load-theme 'base16-ocean t))

(provide 'init)

;;; init.el ends here
