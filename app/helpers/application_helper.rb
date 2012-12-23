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

end
