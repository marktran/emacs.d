;;; weather.el --- 5-day weather forecast via Open-Meteo -*- lexical-binding: t; -*-

(require 'url)
(require 'json)
(require 'cl-lib)

;;; Customization

(defgroup weather nil
  "5-day weather forecast display."
  :group 'applications
  :prefix "weather-")

(defcustom weather-location "Portland"
  "City name for weather forecasts."
  :type 'string
  :group 'weather)

(defcustom weather-units "fahrenheit"
  "Temperature units, \"celsius\" or \"fahrenheit\"."
  :type '(choice (const "celsius") (const "fahrenheit"))
  :group 'weather)

(defcustom weather-buffer-name "*Weather*"
  "Name of the weather forecast buffer."
  :type 'string
  :group 'weather)

(defcustom weather-column-separator "│"
  "Column separator glyph used between day columns."
  :type 'string
  :group 'weather)

(defcustom weather-icon-width-columns 2
  "Rendered icon width in text columns."
  :type 'integer
  :group 'weather)

(defcustom weather-cache-duration 1800
  "Seconds to cache forecast data before re-fetching."
  :type 'integer
  :group 'weather)

;;; Faces

(defface weather-day-header
  '((t :weight bold))
  "Face for day/date headers."
  :group 'weather)

(defface weather-temp-high
  '((t :inherit font-lock-warning-face))
  "Face for high temperatures."
  :group 'weather)

(defface weather-temp-low
  '((t :inherit font-lock-comment-face))
  "Face for low temperatures."
  :group 'weather)

(defface weather-precipitation
  '((t :inherit font-lock-keyword-face))
  "Face for precipitation amounts."
  :group 'weather)

;;; Internal state

(defvar weather--geocode-cache nil
  "Alist of (CITY . (LAT . LON)) cached geocode results.")

(defvar weather--forecast-cache nil
  "Plist (:data DATA :time TIME :location LOC :units UNITS) of cached forecast.")

(defvar weather--icon-cache nil
  "Hash table of icon-name -> image descriptor.")

(defun weather--icon-cache ()
  "Return the icon cache hash table, creating it if needed."
  (unless (hash-table-p weather--icon-cache)
    (setq weather--icon-cache (make-hash-table :test 'equal)))
  weather--icon-cache)

;;; Layout constants

(defconst weather--column-width 14
  "Width of each day column.")

(defconst weather--left-margin 2
  "Left margin before the first column.")

;;; WMO weather code mapping

(defconst weather--wmo-codes
  '((0  "01d" "Clear")
    (1  "01d" "Mostly Clr")
    (2  "02d" "Pt Cloudy")
    (3  "04d" "Overcast")
    (45 "50d" "Fog")
    (48 "50d" "Rime Fog")
    (51 "09d" "Lt Drizzle")
    (53 "09d" "Drizzle")
    (55 "09d" "Hv Drizzle")
    (56 "09d" "Frzg Drzl")
    (57 "09d" "Hv Frz Drzl")
    (61 "10d" "Lt Rain")
    (63 "10d" "Rain")
    (65 "10d" "Heavy Rain")
    (66 "13d" "Frzg Rain")
    (67 "13d" "Hv Frz Rain")
    (71 "13d" "Lt Snow")
    (73 "13d" "Snow")
    (75 "13d" "Heavy Snow")
    (77 "13d" "Snow Grains")
    (80 "09d" "Lt Showers")
    (81 "09d" "Showers")
    (82 "09d" "Hv Showers")
    (85 "13d" "Lt Sn Shwr")
    (86 "13d" "Hv Sn Shwr")
    (95 "11d" "T-Storm")
    (96 "11d" "T-Strm Hail")
    (99 "11d" "Hv T-S Hail"))
  "Alist of (WMO-CODE ICON-NAME DESCRIPTION).
ICON-NAME corresponds to OpenWeatherMap icon codes.")

(defun weather--wmo-lookup (code)
  "Return (ICON-NAME DESCRIPTION) for WMO CODE."
  (let ((entry (assoc code weather--wmo-codes)))
    (if entry
        (cdr entry)
      '("01d" "Unknown"))))

;;; Icon support

(defconst weather--icon-marker "<<<ICON:%d>>>"
  "Format string for icon placeholder markers in the buffer.")

(defun weather--icon-placeholder (col)
  "Return a fixed-width icon placeholder marker for COL."
  (weather--pad-to (format weather--icon-marker col) weather--column-width))

(defun weather--icon-url (icon-name)
  "Return URL for OpenWeatherMap icon ICON-NAME."
  (format "https://openweathermap.org/img/wn/%s.png" icon-name))

(defun weather--image-width-columns (image)
  "Return IMAGE display width in character columns as a float."
  (let* ((size (image-size image nil (selected-frame)))
         (width (and (consp size) (car size))))
    (if (numberp width) (max 1.0 width) 1.0)))

(defun weather--icon-cell-string (image width)
  "Return a WIDTH-column string with IMAGE centered."
  (let* ((image-width (max 1 (round (weather--image-width-columns image))))
         (total-pad (max 0 (- width image-width)))
         (left-pad (/ total-pad 2))
         (right-pad (- total-pad left-pad)))
    (concat (make-string left-pad ?\s)
            (propertize " " 'display image)
            (make-string right-pad ?\s))))

(defun weather--fetch-icon (icon-name col)
  "Fetch icon for ICON-NAME and place it at column COL in the weather buffer."
  (let ((cached (gethash icon-name (weather--icon-cache))))
    (if cached
        (weather--place-icon cached col)
      (url-retrieve
       (weather--icon-url icon-name)
       (lambda (status)
         (unless (plist-get status :error)
           (goto-char (1+ url-http-end-of-headers))
           (let* ((raw (buffer-substring-no-properties (point) (point-max)))
                  (icon-px (max 1 (* weather-icon-width-columns (frame-char-width))))
                  (img (create-image raw 'png t :width icon-px :ascent 'center)))
             (kill-buffer)
             (when img
               (puthash icon-name img (weather--icon-cache))
               (weather--place-icon img col)))))
       nil t t))))

(defun weather--place-icon (image col)
  "Replace icon placeholder for COL with IMAGE in the weather buffer."
  (let ((buf (get-buffer weather-buffer-name))
        (marker (weather--icon-placeholder col)))
    (when (buffer-live-p buf)
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (save-excursion
            (goto-char (point-min))
            (when (search-forward marker nil t)
              (replace-match
               (weather--icon-cell-string image (string-width marker))
               t t))))))))

(defun weather--fetch-icons (icon-names)
  "Fetch and display icons for ICON-NAMES (list of icon name strings)."
  (when (display-images-p)
    (cl-loop for name in icon-names
             for col from 0
             do (weather--fetch-icon name col))))

;;; Async HTTP helpers

(defun weather--url-retrieve (url callback)
  "Fetch URL asynchronously, parse JSON response, call CALLBACK with parsed data.
CALLBACK receives one argument: the parsed JSON object, or nil on error."
  (url-retrieve
   url
   (lambda (status)
     (if (plist-get status :error)
         (progn
           (message "Weather: HTTP error fetching %s" url)
           (kill-buffer)
           (funcall callback nil))
       (goto-char url-http-end-of-headers)
       (condition-case nil
           (let ((data (json-read)))
             (kill-buffer)
             (funcall callback data))
         (error
          (kill-buffer)
          (message "Weather: JSON parse error")
          (funcall callback nil)))))
   nil t t))

;;; Geocoding

(defun weather--geocode (city callback)
  "Geocode CITY to (LAT . LON), calling CALLBACK with the result.
Uses cache when available."
  (let* ((query (car (split-string city ",")))
         (cached (assoc city weather--geocode-cache)))
    (if cached
        (funcall callback (cdr cached))
      (weather--url-retrieve
       (format "https://geocoding-api.open-meteo.com/v1/search?name=%s&count=1"
               (url-hexify-string query))
       (lambda (data)
         (if-let* ((results (and data (cdr (assoc 'results data))))
                   (first (aref results 0))
                   (lat (cdr (assoc 'latitude first)))
                   (lon (cdr (assoc 'longitude first))))
             (progn
               (push (cons city (cons lat lon)) weather--geocode-cache)
               (funcall callback (cons lat lon)))
           (message "Weather: could not geocode \"%s\"" city)
           (funcall callback nil)))))))

;;; Forecast fetching

(defun weather--fetch-forecast (lat lon callback)
  "Fetch 5-day forecast for LAT/LON, calling CALLBACK with (current . daily) data."
  (let ((temp-unit (if (string= weather-units "fahrenheit") "&temperature_unit=fahrenheit" "")))
    (weather--url-retrieve
     (format (concat "https://api.open-meteo.com/v1/forecast?"
                     "latitude=%s&longitude=%s"
                     "&current=temperature_2m,weathercode"
                     "&daily=temperature_2m_max,temperature_2m_min,"
                     "precipitation_sum,weathercode,windspeed_10m_max"
                     "&forecast_days=5&timezone=auto%s")
             lat lon temp-unit)
     (lambda (data)
       (if-let ((daily (and data (cdr (assoc 'daily data)))))
           (let ((current (cdr (assoc 'current data))))
             (setq weather--forecast-cache
                   (list :data (cons current daily)
                         :time (float-time)
                         :location weather-location
                         :units weather-units))
             (funcall callback (cons current daily)))
         (message "Weather: no forecast data returned")
         (funcall callback nil))))))

;;; Rendering

(defun weather--pad-center (str width)
  "Center STR within WIDTH characters."
  (let* ((len (string-width str))
         (pad (max 0 (/ (- width len) 2))))
    (concat (make-string pad ?\s) str)))

(defun weather--pad-to (str width)
  "Center STR in exactly WIDTH characters, padding both sides."
  (let* ((len (string-width str))
         (lpad (max 0 (/ (- width len) 2)))
         (rpad (max 0 (- width len lpad))))
    (concat (make-string lpad ?\s) str (make-string rpad ?\s))))

(defun weather--insert-row (strings &optional face)
  "Insert a row of STRINGS, one per column separated by `weather-column-separator'."
  (insert (make-string weather--left-margin ?\s))
  (let ((first t))
    (dolist (s strings)
      (unless first (insert weather-column-separator))
      (setq first nil)
      (let ((padded (weather--pad-to s weather--column-width)))
        (if face
            (insert (propertize padded 'face face))
          (insert padded)))))
  (insert "\n"))

(defun weather--render (data)
  "Render DATA ((current . daily) cons) into the weather buffer."
  (let* ((current (car data))
         (daily (cdr data))
         (cur-temp (cdr (assoc 'temperature_2m current)))
         (cur-code (cdr (assoc 'weathercode current)))
         (dates (cdr (assoc 'time daily)))
         (highs (cdr (assoc 'temperature_2m_max daily)))
         (lows (cdr (assoc 'temperature_2m_min daily)))
         (precip (cdr (assoc 'precipitation_sum daily)))
         (codes (cdr (assoc 'weathercode daily)))
         (winds (cdr (assoc 'windspeed_10m_max daily)))
         (unit-char (if (string= weather-units "fahrenheit") "F" "C"))
         (wind-unit (if (string= weather-units "fahrenheit") "mph" "km/h"))
         (day-headers '())
         (icon-names '())
         (descs '())
         (high-strs '())
         (low-strs '())
         (precip-strs '())
         (wind-strs '()))
    ;; Build column data
    (dotimes (i (length dates))
      (let* ((date-str (aref dates i))
             (time (date-to-time (concat date-str "T00:00:00")))
             (day-name (format-time-string "%a" time))
             (date-short (format-time-string "%m/%d" time))
             (wmo (weather--wmo-lookup (aref codes i))))
        (push (format "%s %s" day-name date-short) day-headers)
        (push (nth 0 wmo) icon-names)
        (push (nth 1 wmo) descs)
        (push (format "H: %d°%s" (round (aref highs i)) unit-char) high-strs)
        (push (format "L: %d°%s" (round (aref lows i)) unit-char) low-strs)
        (let ((p (aref precip i))
              (w (round (aref winds i))))
          (push (if (> p 0) (format "%.1fmm" p) "") precip-strs)
          (push (if (>= w 20) (format "%d %s" w wind-unit) "") wind-strs))))
    (setq day-headers (nreverse day-headers)
          icon-names (nreverse icon-names)
          descs (nreverse descs)
          high-strs (nreverse high-strs)
          low-strs (nreverse low-strs)
          precip-strs (nreverse precip-strs)
          wind-strs (nreverse wind-strs))
    ;; Only include rows if any day has data
    (unless (cl-some (lambda (s) (not (string-empty-p s))) precip-strs)
      (setq precip-strs nil))
    (unless (cl-some (lambda (s) (not (string-empty-p s))) wind-strs)
      (setq wind-strs nil))
    ;; Render buffer
    (let ((buf (get-buffer-create weather-buffer-name)))
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (erase-buffer)
          (weather-mode)
          ;; Title
          (insert (propertize (format "  %s" weather-location) 'face 'weather-day-header))
          (when cur-temp
            (insert (format "  %d°%s %s"
                            (round cur-temp) unit-char
                            (nth 1 (weather--wmo-lookup cur-code)))))
          (insert "\n\n")
          ;; Day headers
          (weather--insert-row day-headers 'weather-day-header)
          ;; Icon placeholders
          (weather--insert-row
           (cl-loop for i below (length icon-names)
                    collect (weather--icon-placeholder i)))
          ;; Descriptions
          (weather--insert-row descs)
          ;; High temps
          (weather--insert-row high-strs 'weather-temp-high)
          ;; Low temps
          (weather--insert-row low-strs 'weather-temp-low)
          ;; Precipitation (only if any day has rain)
          (when precip-strs
            (weather--insert-row precip-strs 'weather-precipitation))
          ;; Wind (only if any day is particularly windy)
          (when wind-strs
            (weather--insert-row wind-strs))
          (goto-char (point-min))
          (set-buffer-modified-p nil)))
      (pop-to-buffer buf)
      ;; Fetch icons async
      (weather--fetch-icons icon-names))))

;;; Mode definition

(define-derived-mode weather-mode special-mode "Weather"
  "Major mode for displaying weather forecasts."
  ;; Keep separator segments visually continuous across rows.
  (setq-local line-spacing 0)
  :group 'weather)

;;; Entry point

;;;###autoload
(defun weather ()
  "Display a 5-day weather forecast for `weather-location'."
  (interactive)
  (setq weather--forecast-cache nil)
  (message "Weather: fetching forecast for %s..." weather-location)
  (weather--geocode
   weather-location
   (lambda (coords)
     (when coords
       (weather--fetch-forecast
        (car coords) (cdr coords)
        (lambda (daily)
          (when daily
            (weather--render daily))))))))

(provide 'weather)
;;; weather.el ends here
