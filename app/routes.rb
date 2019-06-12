require File.dirname(__FILE__) + '/../lib/routing'

class Routes
  include Routing

  conn = Faraday.new(url: ENV['URL_API']) do |c|
    c.use Faraday::Request::UrlEncoded
    c.use Faraday::Response::Logger
    c.use Faraday::Adapter::NetHttp
  end

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}
    Para listar los comandos disponibles por favor envia /help")
  end

  on_message '/help' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '/oferta Muestra la oferta academica')
    bot.api.send_message(chat_id: message.chat.id, text: '/inscripcion Permite inscribirte a materias de la oferta academica')
    bot.api.send_message(chat_id: message.chat.id, text: '/estado Permite consultar tu estado en una meteria')
  end

  on_message '/oferta' do |bot, message|
    response = conn.get 'materias' do |request|
      request.headers['API_TOKEN'] = ENV['HTTP_API_TOKEN']
    end

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
    response = conn.get 'materias' do |request|
      request.headers['API_TOKEN'] = ENV['HTTP_API_TOKEN']
    end
    subjects = JSON.parse(response.body)
    button_subjects = []
    subjects['oferta'].each do |subject|
      button_subjects.push(Telegram::Bot::Types::InlineKeyboardButton.new(text: subject['materia'], callback_data: subject['codigo']))
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: button_subjects)
    bot.api.send_message(chat_id: message.chat.id, text: 'Seleccione la materia para la inscripcion', reply_markup: markup)
  end

  on_message '/estado' do |bot, message|
    response = conn.get 'materias' do |request|
      request.headers['API_TOKEN'] = ENV['HTTP_API_TOKEN']
    end
    subjects = JSON.parse(response.body)
    button_subjects = []
    subjects['oferta'].each do |subject|
      button_subjects.push(Telegram::Bot::Types::InlineKeyboardButton.new(text: subject['materia'], callback_data: subject['codigo']))
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: button_subjects)
    bot.api.send_message(chat_id: message.chat.id, text: 'Seleccione la materia consultar estado', reply_markup: markup)
  end

  on_response_to 'Seleccione la materia consultar estado' do |bot, message|
    code_message = message.data
    params = { codigoMateria: code_message.to_s, usernameAlumno: message.from.username }
    response = conn.get do |req| # (ENV['URL_API'] + 'alumnos', params.to_json)
      req.url ENV['URL_API'] + 'materias/estado'
      req.headers['API_TOKEN'] = ENV['HTTP_API_TOKEN']
      req.params = params
    end
    request_body = JSON.parse(response.body.gsub('\"', '"'))
    bot.api.send_message(chat_id: message.message.chat.id, text: request_body['estado'])
  end

  on_response_to 'Seleccione la materia para la inscripcion' do |bot, message|
    code_message = message.data
    full_name = message.from.first_name + ' ' + message.from.last_name
    params = { nombre_completo: full_name, codigo_materia: code_message.to_s, username_alumno: message.from.username }
    response = conn.post do |req| # (ENV['URL_API'] + 'alumnos', params.to_json)
      req.url ENV['URL_API'] + 'alumnos'
      req.headers['API_TOKEN'] = ENV['HTTP_API_TOKEN']
      req.body = params.to_json
    end
    bot.api.send_message(chat_id: message.message.chat.id, text: response.body)
  end

  on_response_to 'Seleccione la materia para consultar tu estado' do |bot, message|
    code_message = message.data
    params = { codigo_materia: code_message.to_s, username_alumno: message.from.username }
    response = Faraday.post(ENV['URL_API'] + 'miEstado', params.to_json)
    bot.api.send_message(chat_id: message.message.chat.id, text: response.body)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Podes ver los comandos disponibles con /help')
  end
end
