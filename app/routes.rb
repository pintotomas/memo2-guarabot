require File.dirname(__FILE__) + '/../lib/routing'
class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}
Para listar los comandos disponibles por favor envia /help")
  end

  on_message '/help' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '/oferta Muestra la oferta academica')
    bot.api.send_message(chat_id: message.chat.id, text: '/inscripcion Permite inscribirte a materias de la oferta academica')
    bot.api.send_message(chat_id: message.chat.id, text: '/estado Permite consultar tu estado en una materia')
    bot.api.send_message(chat_id: message.chat.id, text: '/nota Permite consultar tu nota en una materia')
    bot.api.send_message(chat_id: message.chat.id, text: '/misInscripciones Muestra tus inscripciones')
    bot.api.send_message(chat_id: message.chat.id, text: '/promedio Muestra tu cantidad de materias aprobadas y el promedio')
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Podes ver los comandos disponibles con /help')
  end

  def self.show_subjects(subjects)
    button_subjects = []
    subjects.each do |subject|
      button_subjects.push(Telegram::Bot::Types::InlineKeyboardButton.new(text: subject['materia'], callback_data: subject['codigo']))
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: button_subjects)
    markup
  end

  def self.send_get(params, destination_url)
    response = connection.get do |req|
      req.url ENV['URL_API'] + destination_url
      req.headers['API_TOKEN'] = ENV['HTTP_API_TOKEN']
      req.params = params unless params.nil?
    end
    response
  end

  def self.send_post(params, destination_url)
    response = connection.post do |req|
      req.url ENV['URL_API'] + destination_url
      req.headers['API_TOKEN'] = ENV['HTTP_API_TOKEN']
      req.body = params.to_json
    end
    response
  end

  def self.connection
    one_connection = Faraday.new(url: ENV['URL_API']) do |c|
      c.use Faraday::Request::UrlEncoded
      c.use Faraday::Response::Logger
      c.use Faraday::Adapter::NetHttp
    end
    one_connection
  end

  def self.show_subjects_like_info(bot, message, response_json, property)
    response_json[property].each do |subject_info|
      text = ''
      text = text + 'Materia: ' + subject_info['materia'] + ', Codigo:' + String(subject_info['codigo']) + ', Docente:' + subject_info['docente']
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end
end
