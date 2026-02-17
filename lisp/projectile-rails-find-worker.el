(defun projectile-rails-find-worker ()
  (interactive)
  (projectile-rails-find-resource
   "worker: "
   '(("app/workers/" "/workers/\\(.+?\\)\\(_worker\\)?\\.rb\\'"))
   "app/workers/${filename}_worker.rb"))
