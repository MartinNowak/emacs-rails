;;; rails-model-layout.el ---

;; Copyright (C) 2006 Dmitry Galinsky <dima dot exe at gmail dot com>

;; Authors: Dmitry Galinsky <dima dot exe at gmail dot com>

;; Keywords: ruby rails languages oop
;; $URL$
;; $Id$

;;; License

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;;; Code:

(defun rails-model-layout:keymap (type)
  (let* ((name (capitalize (substring (symbol-name type) 1)))
         (map (make-sparse-keymap))
         (menu (make-sparse-keymap)))
    (when type
      (define-keys menu
        ([goto-model]      '(menu-item "Go to Model"
                                       rails-model-layout:switch-to-model
                                       :enable (and (not (eq (rails-core:buffer-type) :model))
                                                    (rails-core:model-exist-p (rails-core:current-model)))))
        ([goto-utest]      '(menu-item "Go to Models Test"
                                       rails-model-layout:switch-to-models-test
                                       :enable (and (not (eq (rails-core:buffer-type) :models-test))
                                                    (rails-core:models-test-exist-p (or (rails-core:current-model)
                                                                                      (rails-core:current-mailer))))))
        ([goto-migration]  '(menu-item "Go to Migration"
                                       rails-model-layout:switch-to-migration
                                       :enable (and (not (eq (rails-core:buffer-type) :migration))
                                                    (rails-core:migration-file-by-model (rails-core:current-model)))))
        ([goto-controller] '(menu-item "Go to Controller"
                                       rails-model-layout:switch-to-controller
                                       :enable (rails-core:controller-file-by-model (rails-core:current-model))))
        ([goto-decorator] '(menu-item "Go to Decorator"
                                       rails-model-layout:switch-to-decorator
                                       :enable (rails-core:decorator-file-by-model (rails-core:current-model))))
        ([goto-fixture]    '(menu-item "Go to Fixture"
                                       rails-model-layout:switch-to-fixture
                                       :enable (and (not (eq (rails-core:buffer-type) :fixture))
                                                    (rails-core:fixture-exist-p (rails-core:current-model)))))
        ([goto-mailer]     '(menu-item "Go to Mailer"
                                       rails-model-layout:switch-to-mailer
                                       :enable (rails-core:mailer-exist-p (rails-core:current-mailer)))))
      (define-keys map
        ((rails-key "m")         'rails-model-layout:switch-to-model)
        ((rails-key "u")         'rails-model-layout:switch-to-models-test)
        ((rails-key "g")         'rails-model-layout:switch-to-migration)
        ((rails-key "c")         'rails-model-layout:switch-to-controller)
        ((rails-key "d")         'rails-model-layout:switch-to-decorator)
        ((rails-key "x")         'rails-model-layout:switch-to-fixture)
        ((rails-key "n")         'rails-model-layout:switch-to-mailer)
        ([menu-bar rails-model-layout] (cons name menu))))
    map))

(defun rails-model-layout:switch-to (type)
  (let* ((name (capitalize (substring (symbol-name type) 1)))
         (model (rails-core:current-model))
         (controller (rails-core:current-controller))
         (mailer (rails-core:current-mailer))
         (item (if controller controller model))
         (item (case type
                 (:mailer (rails-core:mailer-file mailer))
                 (:controller (rails-core:controller-file-by-model model))
                 (:fixture (rails-core:fixture-file model))
                 (:models-test (rails-core:models-test-file item))
                 (:model (rails-core:model-file model))
                 (:decorator (rails-core:decorator-file-by-model model))
                 (:migration (rails-core:migration-file-by-model model)))))
    (if item
      (find-or-ask-to-create (format "%s does not exists do you want to create it? " item)
                             (rails-core:file item))
      (message "%s not found" name))))

(defun rails-model-layout:switch-to-mailer () (interactive) (rails-model-layout:switch-to :mailer))
(defun rails-model-layout:switch-to-controller () (interactive) (rails-model-layout:switch-to :controller))
(defun rails-model-layout:switch-to-fixture () (interactive) (rails-model-layout:switch-to :fixture))
(defun rails-model-layout:switch-to-models-test () (interactive) (rails-model-layout:switch-to :models-test))
(defun rails-model-layout:switch-to-model () (interactive) (rails-model-layout:switch-to :model))
(defun rails-model-layout:switch-to-migration () (interactive) (rails-model-layout:switch-to :migration))
(defun rails-model-layout:switch-to-decorator () (interactive) (rails-model-layout:switch-to :decorator))

(defun rails-model-layout:menu ()
  (interactive)
  (let* ((item (list))
         (type (rails-core:buffer-type))
         (title (capitalize (substring (symbol-name type) 1)))
         (model (rails-core:current-model))
         (controller (pluralize-string model))
         (decorator (rails-core:current-decorator))
         (mailer (rails-core:current-mailer)))
    (when model
      (when (and (not (eq type :migration))
                 (rails-core:migration-file-by-model model))
        (add-to-list 'item (cons "Migration" :migration)))
      (unless (eq type :fixture)
        (add-to-list 'item (cons "Fixture" :fixture)))
      (when (rails-core:controller-exist-p controller)
        (add-to-list 'item (cons "Controller" :controller)))
      (when (rails-core:decorator-exist-p decorator)
        (add-to-list 'item (cons "Decorator" :decorator)))
      (unless (eq type :models-test)
        (add-to-list 'item (cons "Models Test" :models-test)))
      (unless (eq type :model)
        (add-to-list 'item (cons "Model" :model))))
    (when mailer
        (setq item (rails-controller-layout:views-menu model))
        (add-to-list 'item (rails-core:menu-separator))
        (add-to-list 'item (cons "Mailer" :mailer)))
    (when item
      (setq item
            (rails-core:menu
             (list (concat title " " model)
                   (cons "Please select.."
                         item))))
      (typecase item
        (symbol (rails-model-layout:switch-to item))
        (string (rails-core:find-file-if-exist item))))))

(provide 'rails-model-layout)
