module ApplicationHelper
  def to_time(datetime)
    datetime.strftime("%b %m, %Y")
  end

  def highlight_text(text, keyword)
    return text if keyword.blank?

    regex = Regexp.new(Regexp.escape(keyword), Regexp::IGNORECASE)
    text.to_s.gsub(regex) do |match|
      "<mark class='bg-yellow-300 text-black rounded-sm'>#{match}</mark>"
    end.html_safe
  end
end
