require File.dirname(__FILE__) + '/../lib/routing'
require 'byebug'
class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}
Para listar los comandos disponibles por favor envia /help")
  end

  on_message '/oferta' do |bot, message|
    response = Faraday.get 'http://localhost:3000/students/academic_offer'
    bot.api.send_message(chat_id: message.chat.id, text: response.body)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Podes ver los comandos disponibles con /help')
  end
end
