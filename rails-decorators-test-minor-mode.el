;;; rails-decorators-test-minor-mode.el --- minor mode for RubyOnRails decorators tests

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

(define-minor-mode rails-decorators-test-minor-mode
  "Minor mode for RubyOnRails decorators tests."
  :lighter " FTest"
  :keymap (let ((map (rails-decorator-layout:keymap :decorators-test)))
            (define-key map rails-minor-mode-test-current-method-key 'rails-test:run-current-method)
            (define-key map [menu-bar rails-decorator-layout run] '("Test current method" . rails-test:run-current-method))
            map)
  (setq rails-primary-switch-func 'rails-decorator-layout:switch-to-decorator)
  (setq rails-secondary-switch-func 'rails-decorator-layout:menu))

(provide 'rails-decorators-test-minor-mode)
