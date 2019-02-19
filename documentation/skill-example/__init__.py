import re
import sys
import json
from os.path import dirname, join
from adapt.intent import IntentBuilder
from mycroft import MycroftSkill, intent_handler, intent_file_handler
from mycroft.messagebus.message import Message

class SkillExample(MycroftSkill):
    """ 
    Example Skill Showcasing All Delegates
    """
    def __init__(self):
        super().__init__("SkillExample")
    
    def initialize(self):
        # Handle Menu and Navigation
        self.gui.register_handler('skillExample.menu', self.handle_gui_example_menu)
        self.gui.register_handler('skillExample.simpleText', self.handle_gui_example_one_intent)
        self.gui.register_handler('skillExample.simpleImage', self.handle_gui_example_two_intent)
        self.gui.register_handler('skillExample.paginatedText', self.handle_gui_example_three_intent)
        self.gui.register_handler('skillExample.slidingImage', self.handle_gui_example_four_intent)
        self.gui.register_handler('skillExample.proportionalDelegate', self.handle_gui_example_five_intent)
        self.gui.register_handler('skillExample.listView', self.handle_gui_example_six_intent)
        self.gui.register_handler('skillExample.eventsExample', self.handle_gui_example_seven_intent)        
        
        # Handle example events
        self.gui.register_handler('skillExample.colorChange', self.change_color_event)
    
    @intent_file_handler('gui.example.one')
    def handle_gui_example_one_intent(self, message):
        """ 
        Example Intent Showcasing Basic UI Text
        """
        self.gui.show_text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec placerat varius turpis porta scelerisque. Nam feugiat, lectus a ultricies tempus, mi sem tempor felis, vitae laoreet nisi ipsum vitae mauris.")
    
    @intent_file_handler('gui.example.two')
    def handle_gui_example_two_intent(self, message):
        """ 
        Example Intent Showcasing Basic UI Image
        """
        self.gui.show_image("https://source.unsplash.com/1920x1080/?+random")

    @intent_file_handler('gui.example.three')
    def handle_gui_example_three_intent(self, message):
        """ 
        Example Intent Showcasing Paginated UI Text
        """
        self.gui['sampleText'] = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Egestas sed tempus urna et pharetra pharetra massa massa ultricies. Aliquam sem et tortor consequat id porta nibh. Amet est placerat in egestas erat imperdiet sed. Ut ornare lectus sit amet est placerat in egestas erat. Iaculis eu non diam phasellus vestibulum lorem sed risus ultricies. Hac habitasse platea dictumst vestibulum rhoncus est pellentesque. Vulputate eu scelerisque felis imperdiet proin fermentum. Neque convallis a cras semper auctor neque. Pharetra magna ac placerat vestibulum lectus mauris ultrices eros in. Phasellus faucibus scelerisque eleifend donec pretium vulputate. Malesuada bibendum arcu vitae elementum curabitur vitae nunc. Tellus id interdum velit laoreet id donec. Diam donec adipiscing tristique risus nec. Nisi lacus sed viverra tellus in hac habitasse platea. Amet venenatis urna cursus eget nunc scelerisque viverra mauris in. Sit amet nisl suscipit adipiscing bibendum est ultricies. Nec ultrices dui sapien eget mi proin sed. Egestas dui id ornare arcu odio ut sem nulla. Rhoncus aenean vel elit scelerisque. Neque gravida in fermentum et sollicitudin. Pellentesque massa placerat duis ultricies lacus sed. Nunc id cursus metus aliquam eleifend mi. Eu feugiat pretium nibh ipsum consequat nisl. Aenean euismod elementum nisi quis eleifend quam adipiscing vitae. Est ante in nibh mauris cursus mattis. Sagittis eu volutpat odio facilisis mauris sit amet. At consectetur lorem donec massa sapien faucibus. Odio facilisis mauris sit amet. Quis ipsum suspendisse ultrices gravida dictum fusce. Sagittis nisl rhoncus mattis rhoncus urna neque viverra justo nec. Eget mi proin sed libero enim sed faucibus. Interdum velit euismod in pellentesque massa. Et netus et malesuada fames. Velit aliquet sagittis id consectetur purus. Condimentum lacinia quis vel eros donec ac odio tempor orci. Amet consectetur adipiscing elit pellentesque habitant. Eleifend mi in nulla posuere sollicitudin aliquam ultrices sagittis orci. Nisi porta lorem mollis aliquam ut porttitor leo a diam. Egestas integer eget aliquet nibh praesent tristique. Velit scelerisque in dictum non. Id volutpat lacus laoreet non curabitur gravida arcu ac. Suspendisse interdum consectetur libero id faucibus nisl tincidunt eget. Ipsum a arcu cursus vitae congue mauris. Duis at consectetur lorem donec massa. Orci sagittis eu volutpat odio facilisis mauris. Eget mauris pharetra et ultrices neque ornare. Commodo nulla facilisi nullam vehicula ipsum a. Arcu risus quis varius quam quisque. Gravida in fermentum et sollicitudin. Lacus laoreet non curabitur gravida arcu ac tortor dignissim. Netus et malesuada fames ac turpis. Ipsum dolor sit amet consectetur adipiscing. Tellus elementum sagittis vitae et leo duis ut diam quam. Vitae et leo duis ut diam quam nulla. Risus pretium quam vulputate dignissim. Justo laoreet sit amet cursus sit amet dictum sit. Blandit libero volutpat sed cras. Lacus sed viverra tellus in. Ornare lectus sit amet est placerat in egestas erat. Tortor dignissim convallis aenean et tortor at. Tempus quam pellentesque nec nam aliquam. Nisi scelerisque eu ultrices vitae auctor eu augue ut lectus. Consequat id porta nibh venenatis cras sed felis eget. Massa enim nec dui nunc mattis enim ut. Dignissim enim sit amet venenatis urna. Ac tincidunt vitae semper quis lectus nulla at. Sed felis eget velit aliquet sagittis. Vel turpis nunc eget lorem dolor sed viverra. Non consectetur a erat nam at lectus. Iaculis eu non diam phasellus vestibulum. Dolor sit amet consectetur adipiscing elit ut aliquam purus sit. Libero justo laoreet sit amet cursus sit. Tellus pellentesque eu tincidunt tortor. Maecenas volutpat blandit aliquam etiam erat velit scelerisque in. Semper risus in hendrerit gravida rutrum quisque non tellus orci. Diam in arcu cursus euismod quis viverra nibh cras pulvinar. Habitasse platea dictumst quisque sagittis purus sit amet volutpat consequat. Elit ut aliquam purus sit. Dui faucibus in ornare quam viverra orci sagittis eu. Purus ut faucibus pulvinar elementum integer. Condimentum lacinia quis vel eros donec ac odio tempor. At in tellus integer feugiat scelerisque varius morbi. Augue eget arcu dictum varius duis. Aliquam sem et tortor consequat id. Bibendum arcu vitae elementum curabitur vitae. Massa sed elementum tempus egestas sed sed. Suscipit adipiscing bibendum est ultricies. Etiam tempor orci eu lobortis."
        self.gui.show_page("paginationExample.qml")

    @intent_file_handler('gui.example.four')
    def handle_gui_example_four_intent(self, message):
        """ 
        Example Intent Showcasing Sliding Image UI
        """
        self.gui['sampleImage'] = "https://source.unsplash.com/1920x1080/?+random"
        self.gui.show_page("slidingExample.qml")

    @intent_file_handler('gui.example.five')
    def handle_gui_example_five_intent(self, message):
        """ 
        Example Intent Showcasing Proportional Delegate and Autofit Label
        """
        self.gui['sampleText'] = "Loading.."
        self.gui.show_page("proportionalDelegateExample.qml")    

    @intent_file_handler('gui.example.six')
    def handle_gui_example_six_intent(self, message):
        """ 
        Example Intent Showcasing Advanced QML Skills with List and JSON Models
        """
        sampleObject = {}
        sampleList = [{ "text": "Praesent id leo felis", "image": "https://c1.staticflickr.com/8/7246/13792463963_817450e973_b.jpg"}, {"text": "Cras egestas tempus tempus", "image": "https://c1.staticflickr.com/8/7246/13792463963_817450e973_b.jpg"}, {"text": "Habitasse platea dictumst", "image": "https://c1.staticflickr.com/8/7246/13792463963_817450e973_b.jpg"}]
        sampleObject['lorem'] = sampleList
        self.gui['sampleBlob'] = sampleObject
        self.gui['background'] = "https://source.unsplash.com/1920x1080/?+random"
        self.gui.show_page("listViewExample.qml")

    @intent_file_handler('gui.example.seven')
    def handle_gui_example_seven_intent(self, message):
        """
        Example Intent Showcasing Events Between Skill and Display
        """
        self.gui.show_page("eventsExample.qml")
        
    def change_color_event(self, message):
        """
        Change Color Event
        """
        self.gui['fooColor'] = message.data['color']
        self.gui.show_page("eventsExample.qml")
        
    @intent_file_handler('gui.example.menu')
    def handle_gui_example_menu(self, message):
        """
        Build and Show Skill Example Menu To Run Test
        """
        menuObject = {}
        menuList = [{
            "exampleIcon": "beamerblock",
            "exampleLabel": "Simple Text Example",
            "exampleEvent": "skillExample.simpleText"
            },
            {
            "exampleIcon": "beamerblock",
            "exampleLabel": "Simple Image Example",
            "exampleEvent": "skillExample.simpleImage"
            },
            {
            "exampleIcon": "beamerblock",
            "exampleLabel": "Paginated Text Example",
            "exampleEvent": "skillExample.paginatedText"  
            },
            {
            "exampleIcon": "beamerblock",
            "exampleLabel": "Sliding Image Example",
            "exampleEvent": "skillExample.slidingImage"
            },
            {
            "exampleIcon": "beamerblock",
            "exampleLabel": "Proportion Delegate & Autofit Label",
            "exampleEvent": "skillExample.proportionalDelegate"
            },
            {
            "exampleIcon": "beamerblock",
            "exampleLabel": "Cards ListView",
            "exampleEvent": "skillExample.listView"
            },
            {
            "exampleIcon": "beamerblock",
            "exampleLabel": "Events Example",
            "exampleEvent": "skillExample.eventsExample"
            }]
        menuObject['menuItems'] = menuList
        self.gui['menuBlob'] = menuObject
        self.gui.show_page("exampleMenu.qml")
        
        
    def stop(self):
        pass


def create_skill():
    return SkillExample()
