module ApplicationHelper

  # Generiert den Titel für die Seiten
	def full_title(page_title)
		base_title=I18n.t('misc.appname')
		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end
  def format(string)
    simple_format(clean(string))
  end
  def clean(string)
    return string unless string.is_a? String

    # Try it as UTF-8 directly
    cleaned = string.dup.force_encoding('UTF-8')
    if cleaned.valid_encoding?
      cleaned
    else
      # Some of it might be old Windows code page
      string.encode(Encoding::UTF_8, Encoding::Windows_1250)
    end
  end

end
