require 'scamp/message'

class Scamp
  module Campfire
    class Message < Scamp::Message
      def valid?(conditions={})
        room_match?(conditions[:room]) &&
        user_match?(conditions[:user])
      end

      def matches? trigger
        adapter.bot.logger.debug "Matching message body #{body} against trigger #{trigger}"
        if adapter.required_prefix
          if satisfies_required_prefix?
            msg = body.split(adapter.required_prefix, 2)[1]
            match? trigger, msg
          else
            return false
          end
        else
          match? trigger, body
        end
      end

      def user_name
        adapter.username_for_user_id(user_id)
      end

      private

      def room_match?(condition)
        return true if condition.nil?

        if condition.is_a? Array
          return (condition.include?(room.id) || condition.include?(room.name))
        elsif condition.is_a? Fixnum
          return room.id == condition
        else
          return room.name.downcase == condition.to_s.downcase
        end
      end

      def user_match?(condition)
        return true if condition.nil?

        if condition.is_a? Array
          return (condition.include?(user.id) || condition.include?(user.name))
        elsif condition.is_a? Fixnum
          return user.id == condition
        else
          return user.name.downcase == condition.to_s.downcase
        end
      end

      def satisfies_required_prefix?
        if adapter.required_prefix
          if adapter.required_prefix.is_a? String
            return true if adapter.required_prefix == body[0...adapter.required_prefix.length]
          elsif adapter.required_prefix.is_a? Regexp
            return true if adapter.required_prefix.match body
          end
          return false
        else
          return true
        end
      end

    end
  end
end
