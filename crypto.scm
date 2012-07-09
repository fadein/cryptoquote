#!/var/lib/bin/csi -s

; return a function that upon each invocation returns the next
; letter of the alphabet, #f when exhausted
(define letter-seq
  (lambda ()
	(let ((letters (string->list "abcdefghijklmnopqrstuvwxyz")))
	  (lambda ()
		(if (null? letters)
		  #f
		  (let ((h (car letters)))
			(set! letters (cdr letters))
			h))))))

; map a word into a "pattern" highlighting repeated letters
; e.g. "gentoo"  -> "abcdee"
;      "level"   -> "abcba"
;      "pattern" -> "abccdef"
;      "ain't"   -> "abc'd"
;      "I'm"     -> "a'b"
(define word->pattern
  (lambda (w)
	(list->string
	  (let ((next-letter (letter-seq)))
		(let loop ((chars (string->list (string-downcase w)))
				   (letters '()))
		  (if (null? chars)
			'()
			(let ((h (car chars)))
			  (cond
				((not (char-alphabetic? h))
				 (cons h (loop (cdr chars) letters)))
				((assq h letters)
				 => (lambda (r)
					  (cons (cdr r) (loop (cdr chars) letters))))
				(else
				  (let ((n (next-letter)))
					(cons n (loop (cdr chars)
								  (cons (cons h n) letters)))))))))))))

; vim:set ft=scheme:
