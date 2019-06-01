require File.dirname(__FILE__) + '/../lib/routing'

class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}
Para listar los comandos disponibles por favor envia /help")
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Podes ver los comandos disponibles con /help')
  end
end
