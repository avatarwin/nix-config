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


(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(load "~/.emacs.d/secrets.el" t)

(package-initialize t)

(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)

(tool-bar-mode -1)
(ido-mode t)

(straight-use-package 'zerodark-theme)
(setq custom-theme-directory "~/.emacs.d/themes")
(load-theme 'zerodark)

(straight-use-package 'auto-package-update)
(straight-use-package 'comment-tags)
(straight-use-package 'cmake-mode)
(straight-use-package 'hl-fill-column)
  (require 'hl-fill-column)
(straight-use-package 'cider)
(straight-use-package 'dynamic-spaces)
(straight-use-package 'dired-k)
  (add-hook 'dired-after-readin-hook #'dired-k-no-revert)
(straight-use-package 'el-get)
(straight-use-package 'eyebrowse)
  (eyebrowse-mode t)
(straight-use-package 'go-mode)
(straight-use-package 'highlight-parentheses)
(straight-use-package 'lua-mode)
(straight-use-package 'magit)
(straight-use-package 'meson-mode)
(straight-use-package 'multiple-cursors)

(straight-use-package 'nim-mode)
(straight-use-package 'nix-mode)

(straight-use-package 'pmdm)
(straight-use-package 'persistent-scratch)
(straight-use-package 'projectile)
(straight-use-package 'pyvenv)
(straight-use-package 'rainbow-delimiters)
(straight-use-package 'rainbow-mode)
(straight-use-package 'rust-mode)
  (setq rust-indent-offset 2)
(straight-use-package 'prog-fill)

(straight-use-package 'slime)
  (setq inferior-lisp-program "sbcl"
	slime-contribs '(slime-scratch slime-repl))

(straight-use-package 'yasnippet)
  (yas-global-mode 1)
(straight-use-package
 '(new-comment-dwim :type git :host github :repo "avatarwin/new-comment-dwim"))
;; '(new-comment-dwim :type git :local-repo "/home/nicola/source/new-comment-dwim"))

(progn
  (defun my/new-commenting ()
    (highlight-parentheses-mode)
    (local-set-key (kbd "M-;") 'ns/comment-insert)
    (local-set-key (kbd "M-j") 'ns/comment-newline))

  (add-hook 'lisp-mode-hook 'my/new-commenting)
  (add-hook 'scheme-mode-hook 'my/new-commenting)
  (add-hook 'emacs-lisp-mode-hook 'my/new-commenting))


(make-variable-buffer-local 'compile-command)


(setq-default python-indent-offset 2
							tab-width 2
							css-indent-offset 2
							sh-basic-offset 2
							indent-tabs-mode nil
              show-trailing-whitespace 't
              ns/comment-default-size 3
              ns/header-comment-default-size 4 )

(defun my-cmode-hook ()
	(set-fill-column 72)
	(hl-fill-column-mode))

(add-hook 'c-mode-common-hook 'my-cmode-hook)

(defun no-trailing-whitespace-hook ()
  (setq show-trailing-whitespace nil))

(add-hook 'slime-repl-mode-hook 'no-trailing-whitespace-hook)
(add-hook 'comint-mode-hook  'no-trailing-whitespace-hook)

(defun macos-config ()
  (global-set-key (kbd "<home>")
                  'move-beginning-of-line)
  (global-set-key (kbd "<end>")
		  'move-end-of-line)
  (set-face-attribute 'default nil
		      :family "Menlo"
		      :height 140)
  (setq scheme-program-name "~/.chicken/bin/csi -:c"))

(defun linux-config ()
  (menu-bar-mode -1)
  ;; (set-face-attribute 'default nil
	;; 	      :family "Inconsolata"
	;; 	      :height 140)
  (setq python-shell-interpreter "python3"
	python-shell-interpreter-args "-i"
	scheme-program-name "csi -:c"))

(defun windows-config ()
  (menu-bar-mode -1)
  (set-face-attribute 'default nil
		      :family "Consolas"
		      :height 140)
  (setq scheme-program-name "c:/chicken/bin/csi.exe -:c"))

(cond ((eq system-type 'darwin)
       (macos-config))
      ((eq system-type 'gnu/linux)
       (linux-config))
      ((eq system-type 'windows-nt)
       (windows-config)))


(setenv "PAGER" "cat")

