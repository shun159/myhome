(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq auto-save-default nil)
(setq x-select-enable-clipboard t)
(setq set-buffer-file-coding-system 'utf-8-emacs)

(setq tab-width 2) ;; or any other preferred value
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq standard-indent 2)

(prefer-coding-system 'utf-8-emacs)
(setq quail-japanese-use-double-n 't)
(setq gnutls-min-prime-bits 1024)

;;; *.~ とかのバックアップファイルを作らない
(setq make-backup-files nil)
;;; .#* とかのバックアップファイルを作らない
(setq auto-save-default nil)

(require 'package)
(setq-default indent-tabs-mode nil)

; Add package-archives
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/")) ; ついでにmarmaladeも追加
; Initialize
(package-initialize)

;;alpha

(add-to-list 'default-frame-alist '(alpha . 100))

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

(package-install 'elscreen)
(require 'elscreen)
(package-install 'smartrep)
(require 'smartrep)
(global-wakatime-mode)

(require 'powerline)
;;(set-face-attribute 'mode-line nil
;;                    :foreground "#fff"
;;                    :background "#FF0066"
;;                    :box nil)
;;(set-face-attribute 'powerline-active1 nil
;;                    :foreground "#fff"
;;                    :background "#FF6699"
;;                    :inherit 'mode-line)
;;(set-face-attribute 'powerline-active2 nil
;;                    :foreground "#000"
;;                    :background "#ffaeb9"
;;                    :inherit 'mode-line)
;;
(powerline-default-theme)

(require 'mozc)
(set-language-environment "Japanese")
(setq default-input-method "japanese-mozc")
(setq mozc-candidate-style 'echo-area)

;; カーソルカラーを設定する
(setq mozc-cursor-color-alist '((direct        . "red")
                                (read-only     . "yellow")
                                (hiragana      . "green")
                                (full-katakana . "goldenrod")
                                (half-ascii    . "dark orchid")
                                (full-ascii    . "orchid")
                                (half-katakana . "dark goldenrod")))

;; C-o で IME をトグルする
(global-set-key (kbd "C-o") 'toggle-input-method)

;; IME が ON の時、カーソルの移動が遅くなるのを改善する
(setq w32-pipe-read-delay 10)

;; minibuffer に入った時、IME を OFF にする
(add-hook 'minibuffer-setup-hook
          (lambda ()
            ;; isearch の中でなければ input-method を無効にする（他に良い判定方法があれば、変更してください）
            (unless (memq 'isearch-done kbd-macro-termination-hook)
              (if (>= (string-to-number emacs-version) 24.3)
                  (deactivate-input-method)
                (deactivate-input-method)))))

;; helm の検索パターンを mozc を使って入力した場合にエラーが発生することがあるのを改善する
(defadvice mozc-helper-process-recv-response (around ad-mozc-helper-process-recv-response activate)
  (while (not ad-return-value)
    ad-do-it))

;; helm の検索パターンを mozc を使って入力する場合、入力中は helm の候補の更新を停止する
(defadvice mozc-candidate-dispatch (before ad-mozc-candidate-dispatch activate)
  (if (and (fboundp 'helm-alive-p)
           (helm-alive-p))
      (let ((method (ad-get-arg 0)))
        (cond ((eq method 'update)
               (unless helm-suspend-update-flag
                 (helm-kill-async-processes)
                 (setq helm-pattern "")
                 (setq helm-suspend-update-flag t)))
              ((eq method 'clean-up)
               (if helm-suspend-update-flag
                   (setq helm-suspend-update-flag nil)))))))

;; helm で候補のアクションを表示する際に IME を OFF にする
(defadvice helm-select-action (before ad-helm-select-action-for-mozc activate)
  (if (>= (string-to-number emacs-version) 24.3)
      (deactivate-input-method)
    (deactivate-input-method)))

;; wdired 終了時に IME を OFF にする
(require 'wdired)
(defadvice wdired-finish-edit (after ad-wdired-finish-edit activate)
  (if (>= (string-to-number emacs-version) 24.3)
      (deactivate-input-method)
    (deactivate-input-mexthod)))

(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)
(global-auto-complete-mode t)

(package-install 'magit)
(require 'magit)
(setq magit-auto-revert-mode nil)
(setq magit-last-seen-setup-instructions "1.4.0")
(dolist (archive '(("melpa" . "http://melpa.milkbox.net/packages/")))
  (add-to-list 'package-archives archive :append))
(package-initialize)

(when (null package-archive-contents)
  (package-refresh-contents))

;;(setq load-path (cons "/usr/lib/erlang/lib/tools-2.8.4/emacs" load-path))
;;(setq erlang-root-dir "/usr/lib/erlang")
;;(setq exec-path (cons "/usr/lib/erlang/bin" exec-path))
;;(require 'erlang-start)

(add-hook 'erlang-mode-hook
          (lambda ()
            (setq inferior-erlang-machine-options
                  (append (remove nil
                                  (mapcan (lambda (app-path)
                                            (let ((ebin (concat app-path "/ebin")))
                                              (when (file-readable-p ebin)
                                                (list "-pa" ebin))))
                                          (directory-files "../.." t "[^.]$")))
                          (remove nil
                                  (mapcan (lambda (dep)
                                            (let ((dep-path (concat dep "/deps")))
                                              (when (file-readable-p dep-path)
                                                (mapcan (lambda (dir)
                                                          (list "-pz" (concat dir "/ebin")))
                                                        (directory-files dep-path t "[^.]$")))))
                                          (directory-files "../.." t "[^.]$"))))
                  erlang-compile-extra-opts
                  (append (remove nil
                                  (mapcan (lambda (app-path)
                                            (let ((ebin (concat app-path "/ebin")))
                                              (when (file-readable-p ebin)
                                                (list 'i ebin))))
                                          (directory-files "../.." t "[^.]$")))
                          (remove nil
                                  (mapcan (lambda (dep)
                                            (let ((dep-path (concat dep "/deps")))
                                              (when (file-readable-p dep-path)
                                                (mapcar (lambda (dir)
                                                          (cons 'i (concat dir "/ebin")))
                                                        (directory-files dep-path t "[^.]$")))))
                                          (directory-files "../.." t "[^.]$")))))))

(add-to-list 'erlang-mode-hook
              (defun auto-activate-auto-complete-mode-for-erlang-mode ()
                (require 'auto-complete)
                (auto-complete-mode 't)))
(add-to-list 'auto-mode-alist '("\\.erl$" . erlang-mode))
(add-to-list 'auto-mode-alist '("reber.config$" . erlang-mode))
(add-to-list 'auto-mode-alist '("reltool.config$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\app.src$" . erlang-mode))

(package-install 'elixir-mode)
(require 'elixir-mode)
(add-to-list 'elixir-mode-hook
             (defun auto-activate-ruby-end-mode-for-elixir-mode ()
               (require 'auto-complete)
               (auto-complete-mode 't)
               (set (make-variable-buffer-local 'ruby-end-expand-keywords-before-re)
                    "\\(?:^\\|\\s-+\\)\\(?:do\\)")
               (set (make-variable-buffer-local 'ruby-end-check-statement-modifiers) nil)
               (ruby-end-mode +1)))

(require 'ruby-mode)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq ruby-deep-indent-paren-style nil)
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-hook 'ruby-mode-hook
          '(lambda ()
             (add-hook 'ruby-mode-hook '(lambda () (auto-complete-mode 't)))
             (setq tab-width 2)
             (setq ruby-indent-level tab-width)
             (setq ruby-deep-indent-paren-style nil)
             (define-key ruby-mode-map [return] 'ruby-reindent-then-newline-and-indent)))

(package-install 'ruby-block)
(require 'ruby-block)
(setq ruby-block-highlight-toggle t)
(add-hook 'ruby-mode-hook '(lambda () (ruby-block-mode 't)))

(package-install 'ruby-electric)
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode 't)))
(electric-pair-mode t)
(add-to-list 'electric-pair-mode '(?| . ?|))
(describe-mode)
(setq ruby-electric-expand-delimiters-list nil)

(require 'linum)
(global-linum-mode t)
(setq linum-format "%3d ")
(line-number-mode t)

(require 'rubocop)
(add-hook 'ruby-mode-hook '(lambda () (rubocop-mode 't)))

;;(require 'ruby-end-mode)
(add-hook 'ruby-mode-hook '(lambda () (ruby-end-mode 't)))

(package-install 'inf-ruby)
(require 'inf-ruby)
(setq inf-ruby-default-implementation "pry")
(setq inf-ruby-eval-binding "Pry.toplevel_binding")
(add-hook 'inf-ruby-mode-hook 'ansi-color-for-comint-mode-on)
(add-hook 'ruby-mode-hook '(lambda () (inf-ruby 't)))

(package-install 'robe)
(require 'robe)
(add-hook 'ruby-mode-hook 'robe-mode)

(package-install 'flycheck)
(require 'flycheck)
(add-hook 'erlang-mode-hook 'flycheck-mode)
(add-hook 'ruby-mode-hook 'flycheck-color-mode-line-mode)
(setq flycheck-check-syntax-automatically '(mode-enabled save))
(add-hook 'ruby-mode-hook 'flycheck-mode)
(flycheck-define-checker ruby-rubocop
  "A Ruby syntax and style checker using the RuboCop tool."
  :command ("rubocop" "--format" "emacs"
            (config-file "--config" flycheck-rubocoprc)
            source)
  :error-patterns
  ((warning line-start
            (file-name) ":" line ":" column ": " (or "C" "W") ": " (message)
            line-end)
   (error line-start
          (file-name) ":" line ":" column ": " (or "E" "F") ": " (message)
          line-end))
  :modes (enh-ruby-mode motion-mode))

;; definition for flycheck
(flycheck-define-checker ruby-rubylint
  "A Ruby syntax and style checker using the rubylint tool."
  :command ("ruby-lint" source)
  :error-patterns
  ((warning line-start
            (file-name) ":" line ":" column ": " (or "C" "W") ": " (message)
            line-end)
   (error line-start
          (file-name) ":" line ":" column ": " (or "E" "F") ": " (message)
          line-end))
  :modes (enh-ruby-mode ruby-mode))

(flycheck-define-checker ruby-rubocop
  "A Ruby syntax and style checker using the RuboCop tool."
  :command ("rubocop" "--format" "emacs"
    (config-file "--config" flycheck-rubocoprc)
    source)
  :error-patterns
  ((warning line-start
    (file-name) ":" line ":" column ": " (or "C" "W") ": " (message)
    line-end)
   (error line-start
	  (file-name) ":" line ":" column ": " (or "E" "F") ": " (message)
	  line-end))
  :modes (enh-ruby-mode motion-mode))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Source Code Pro for Powerline" :foundry "ADBE" :slant normal :weight normal :height 83 :width normal)))))

;; load your favorite theme
(load-theme 'desert t t)
(enable-theme 'desert)
(put 'downcase-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(wakatime-api-key "12c5fdd4-a124-4601-801d-2ddc384754e3"))
