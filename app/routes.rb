require File.dirname(__FILE__) + '/../lib/routing'

class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}
Para listar los comandos disponibles por favor envia /help")
  end

  on_message '/help' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '/oferta Muestra la oferta academica

/inscripcion Permite inscribirte a materias de la oferta academica')
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

  on_message '/inscripcion' do |bot, message|
    response = Faraday.get ENV['URL_API'] + 'materias'
    subjects = JSON.parse(response.body)
    button_subjects = []
    subjects['oferta'].each do |subject|
      button_subjects.push(Telegram::Bot::Types::InlineKeyboardButton.new(text: subject['materia'], callback_data: subject['codigo']))
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: button_subjects)
    bot.api.send_message(chat_id: message.chat.id, text: 'Seleccione la materia para la inscripcion', reply_markup: markup)
  end

  on_response_to 'Seleccione la materia para la inscripcion' do |bot, message|
    code_message = message.data
    full_name = message.from.first_name + ' ' + message.from.last_name
    params = { nombre_completo: full_name, codigo_materia: code_message.to_s, username_alumno: message.from.username }
    response = Faraday.post(ENV['URL_API'] + 'alumnos', params.to_json)
    bot.api.send_message(chat_id: message.message.chat.id, text: response.body)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Podes ver los comandos disponibles con /help')
  end
end
