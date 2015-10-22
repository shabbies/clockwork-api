class Contest < ActiveRecord::Base
	nilify_blanks
	validates_format_of :email, :with => /.+@.+\..+/i
end
