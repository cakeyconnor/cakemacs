(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order
  '(elpaca :repo "https://github.com/progfolio/elpaca.git"
           :ref nil :depth 1 :inherit ignore
           :files (:defaults "elpaca-test.el" (:exclude "extensions"))
           :build (:not elpaca--activate-package)))
(let* ((repo (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Enable use-package integration
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq elpaca-use-package-by-default t))

(elpaca-wait)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  :config
  (evil-mode 1))

   (use-package evil-collection
    :after evil
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer))
    (evil-collection-init))

(use-package general
  :config
  (general-create-definer cakemacs/binds
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") 

  (cakemacs/binds
   "x" '(execute-extended-command :wk "Consult M-x")
   "."   '(dired :wk "Find file")

   "f c" '((lambda () (interactive) (find-file "~/.cakemacs.d/cakemacs.org")) :wk "Edit Emacs configuration")
   "f r" '(consult-recent-file :wk "Find recent files")
   "TAB TAB" '(comment-line :wk "Comment lines")

   ;; Buffer Management
   "b"   '(:ignore t :wk "Buffer Management")
   "b b" '(consult-buffer :wk "Switch buffer")
   "b i" '(ibuffer :wk "Ibuffer")
   "b k" '(kill-this-buffer :wk "Kill this buffer")
   "b n" '(next-buffer :wk "Next buffer")
   "b p" '(previous-buffer :wk "Previous buffer")
   "b r" '(revert-buffer :wk "Reload buffer")

   ;; Help
   "h" '(:ignore t :wk "Help")
   "h f" '(describe-function :wk "Describe function")
   "h t" '(load-theme :wk "Load theme")
   "h v" '(describe-variable :wk "Describe variable")
   "h r r" '(reload-init-file :wk "Reload emacs config")
   
   ;; Search
   "s"   '(:ignore t :wk "Search")
   "s g" '(consult-git-grep :wk "Git repo grep")
   "s k" '(consult-keep-lines :wk "Keep matching lines")
   "s m" '(consult-mark :wk "Jump to marks")
   "s r" '(consult-ripgrep :wk "Search in project")
   "s s" '(consult-line :wk "Search in buffer")
   "s u" '(consult-focus-lines :wk "Focus visible region")
   "s y" '(consult-yank-pop :wk "Clipboard history")

   ;; Toggle
   "t" '(:ignore t :wk "Toggle")
   "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
   "t n" '(neotree-toggle :wk "Toggle neotree file viewer")
   "t t" '(visual-line-mode :wk "Toggle truncated lines")
   "t v" '(vterm-toggle :wk "Toggle vterm")

   ;; Window Management
   "w"   '(:ignore t :wk "Window Management")
   "w c" '(evil-window-delete :wk "Close window")
   "w n" '(evil-window-new :wk "New window")
   "w s" '(evil-window-split :wk "Horizontal split")
   "w v" '(evil-window-vsplit :wk "Vertical split")
   "w h" '(evil-window-left :wk "Focus left")
   "w j" '(evil-window-down :wk "Focus down")
   "w k" '(evil-window-up :wk "Focus up")
   "w l" '(evil-window-right :wk "Focus right")
   "w w" '(evil-window-next :wk "Next window")
   "w H" '(buf-move-left :wk "Buffer move left")))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
(interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
  "Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
(interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
  "Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
(interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(setq backup-directory-alist '((".*" . "~/.cakemacs.d/resources/backups")))

(use-package company
  :defer 2
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :hook (company-mode . company-box-mode))

(use-package dashboard
:ensure t 
:init
(setq initial-buffer-choice 'dashboard-open)
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)
(setq dashboard-banner-logo-title "Welcome to CakeMacs, the best operating system.")
;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
(setq dashboard-startup-banner "~/.cakemacs.d/resources/images/cakemacs.png")  ;; use custom image as banner
(setq dashboard-center-content nil) ;; set to 't' for centered content
(setq dashboard-items '((recents . 5)
                        ;;(agenda . 5 )
                        ;;(bookmarks . 3)
                        (projects . 3)))
                        ;;(registers . 3)))
:custom 
(dashboard-modify-heading-icons '((recents . "file-text")
				      (projects . "book")))
:config
(dashboard-setup-startup-hook))

(use-package flycheck
:ensure t
:defer t
:init (global-flycheck-mode))

(set-face-attribute 'default nil
    :font "JetBrains Mono Nerd Font"
    :height 110
    :weight 'medium)
  (set-face-attribute 'variable-pitch nil
    :font "Ubuntu Nerd Font"
    :height 120
    :weight 'medium)
  (set-face-attribute 'fixed-pitch nil
    :font "JetBrains Mono Nerd Font"
    :height 110
    :weight 'medium)
  ;; Makes commented text and keywords italics.
  ;; This is working in emacsclient but not emacs.
  ;; Your font must have an italic face available.
  (set-face-attribute 'font-lock-comment-face nil
    :slant 'italic)
  (set-face-attribute 'font-lock-keyword-face nil
    :slant 'italic)

  ;; This sets the default font on all graphical frames created after restarting Emacs.
  ;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
  ;; are not right unless I also add this method of setting the default font.
  (add-to-list 'default-frame-alist '(font . "JetBrains Mono Nerd Font-11"))

  ;; Uncomment the following line if line spacing needs adjusting.
  (setq-default line-spacing 0.12)

 ;; Changes the font size of the ORG mode titles
(custom-set-faces
 '(org-level-1 ((t (:inherit default :weight bold :height 1.5))))
 '(org-level-2 ((t (:inherit default :weight bold :height 1.4))))
 '(org-level-3 ((t (:inherit default :weight bold :height 1.3))))
 '(org-level-4 ((t (:inherit default :weight bold :height 1.2))))
 '(org-level-5 ((t (:inherit default :weight bold :height 1.1))))
 '(org-level-6 ((t (:inherit default :weight bold :height 1.05))))
 '(org-level-7 ((t (:inherit default :weight bold :height 1.0))))
 '(org-level-8 ((t (:inherit default :weight bold :height 1.0)))))

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

;; add your language modes here!

;; LSP Mode
;; (use-package lsp-mode
;;   :hook ((python-mode . lsp))  ;; auto-start lsp in Python
;;   :commands lsp
;;   :config
;;   (setq lsp-enable-symbol-highlighting t
;;         lsp-enable-snippet t
;;         lsp-prefer-flymake nil    ;; use flycheck instead of flymake if available
;;         lsp-headerline-breadcrumb-enable t))

;; ;; LSP UI
;; (use-package lsp-ui
;;   :after lsp-mode
;;   :commands lsp-ui-mode
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :config
;;   (setq lsp-ui-doc-enable t
;;         lsp-ui-doc-delay 0.3
;;         lsp-ui-doc-position 'at-point
;;         lsp-ui-sideline-enable t
;;         lsp-ui-sideline-show-code-actions t
;;         lsp-ui-sideline-show-diagnostics t
;;         lsp-ui-sideline-delay 0.2))

;; ;; (use-package company
;;   ;; :hook (after-init . global-company-mode)
  ;; :config
  ;; (setq company-idle-delay 0.1
        ;; company-minimum-prefix-length 1))

;; (use-package flycheck
  ;; :init (global-flycheck-mode))

(use-package doom-modeline
:ensure t
:init (doom-modeline-mode 1))

(use-package neotree
:ensure t
:config
(setq neo-smart-open t
      neo-show-hidden-files t
      neo-window-width 55
      neo-window-fixed-size nil
      inhibit-compacting-font-caches t
      projectile-switch-project-action 'neotree-projectile-action)

;; truncate long file names in neotree buffer
(add-hook 'neo-after-create-hook
          (lambda (_)
            (with-current-buffer (get-buffer neo-buffer-name)
              (setq truncate-lines t)
              (setq word-wrap nil)
              (make-local-variable 'auto-hscroll-mode)
              (setq auto-hscroll-mode nil))))

;; Evil bindings for neotree
(add-hook 'neotree-mode-hook
          (lambda ()
            (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
            (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
            (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
            (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
            (evil-define-key 'normal neotree-mode-map (kbd "p") 'neotree-previous-line))))

(use-package toc-org
:commands toc-org-enable
:init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(require 'org-tempo)

(setq org-startup-with-inline-images t) ;; Show images on file open

(add-hook 'org-babel-after-execute-hook #'org-display-inline-images)

(use-package peep-dired
  :after dired
  :hook (evil-normalize-keymaps . peep-dired-hook)
  :config
  (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
  (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
  (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
  (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file))

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-mode
  :hook org-mode prog-mode)

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(use-package vterm)

(use-package vterm-toggle
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 ;;(display-buffer-reuse-window display-buffer-in-direction)
                 ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                 ;;(direction . bottom)
                 ;;(dedicated . t) ;dedicated is supported in emacs27
                 (reusable-frames . visible)
                 (window-height . 0.4))))

(use-package doom-themes
:config
(setq doom-themes-enable-bold t    
      doom-themes-enable-italic t)
(load-theme 'doom-nord t)
(doom-themes-neotree-config)
(doom-themes-org-config))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package consult
  :init
  (setq consult-preview-key 'any))

(use-package embark
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(setq enable-recursive-minibuffers t)

(use-package which-key
:init
  (which-key-mode 1)
:config
(setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit t
	  which-key-separator " → " ))
