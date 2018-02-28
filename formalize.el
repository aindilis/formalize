(global-set-key "\C-cfmw" 'formalize-lookup-wordnet-wqd)

;;   forward-op		Function to call to skip forward over a "thing" (or
;;                      with a negative argument, backward).
;;
;;   beginning-op	Function to call to skip to the beginning of a "thing".
;;   end-op		Function to call to skip to the end of a "thing".

(defun forward-wqd (arg)
  (interactive "p")
  (if (natnump arg)
      (re-search-forward "\[-#[:alnum:]\]+" nil 'move arg)
    (while (< arg 0)
      (if (re-search-backward "\[-#[:alnum:]\]+" nil 'move)
       (skip-chars-backward "-#abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
      (setq arg (1+ arg)))))

(defun formalize-lookup-wordnet-wqd ()
 "Look up the meaning of a particular wordnet sense"
 (interactive)
 (see (uea-query-agent-raw (concat "wqd " (thing-at-point 'wqd)) "WSD")))

