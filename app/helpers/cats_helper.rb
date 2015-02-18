module CatsHelper
  def localize_date(date)
    return '--' if date.nil?
    I18n.l date, format: :short
   end
end
