require File.dirname(__FILE__) + '/../lib/routing'
class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}
Para listar los comandos disponibles por favor envia /help")
  end

  on_message '/help' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '/oferta Muestra la oferta academica')
  end

  on_message '/oferta' do |bot, message|
    response = Faraday.get ENV['URL_API'] + 'materias'
    response_json = JSON.parse(response.body)
    if response_json['oferta'] == []
      bot.api.send_message(chat_id: message.chat.id, text: 'No hay oferta academica')
    else
      text = ''
      response_json['oferta'].each do |subject_info|
        text = text + 'Materia: ' + subject_info['materia'] + ', Codigo:' + String(subject_info['codigo']) + ', Docente:' + subject_info['docente'] + '

'
      end
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Podes ver los comandos disponibles con /help')
  end
end
