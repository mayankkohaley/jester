require_relative 'helper'

describe "Jester" do
  let(:server) { Newman.new_test_server(Jester::Application) }
  let(:mailer) { server.mailer }
  
  it "responds with a help document" do
    mailer.deliver_message(:to => 'test@test.com', :subject => 'help')
    server.tick
    mailer.messages.first.subject.must_equal("How to use Jester")
  end
  
  it "responds with failure message when the subject does not match" do
    mailer.deliver_message(:to => 'test@test.com')
    server.tick
    mailer.messages.first.subject.must_equal("Sorry, didn't understand your request")
  end
    
  it "responds with successful messages after a story is stored" do
    mailer.deliver_message(:to => 'test@test.com',
                           :subject => "a {genre} story '{title}'")
  
    server.tick
    mailer.messages.first.subject.must_equal("Jester saved '{title}'")                  
         
    mailer.deliver_message(:to => 'test@test.com',
                           :subject => "what stories do you know?")

    server.tick
    mailer.messages.first.subject.must_equal("All of Jester's stories")
    
    mailer.deliver_message(:to => 'test@test.com',
                           :subject => "tell me something {genre}")
    
    server.tick
    mailer.messages.first.subject.must_equal('{title}')
    
    mailer.deliver_message(:to => 'test@test.com',
                           :subject => "tell me '{title}'")
                           
    server.tick
    mailer.messages.first.subject.must_equal('{title}')                           
    
    mailer.deliver_message(:to => 'test@test.com',
                           :subject => "tell something {genre} to {email}")
    
    server.tick
  end
  
  it "respond with an error message when story is not stored in jester" do
    mailer.deliver_message(:to => 'test@test.com',
                           :subject => "tell me '{title}'")
    server.tick
    mailer.messages.first.subject.must_equal("Couldn't find '{title}'")
  end
  
  after do
    if File.exist?(server.settings.application.jester_db) 
      File.unlink(server.settings.application.jester_db) 
    end
  end

end