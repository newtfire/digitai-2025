import os
import json
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer, DataCollatorForLanguageModeling
from datasets import load_dataset
from digitaiCore.utils.configLoader import ConfigLoader

class TrainingLauncher:
    """
    Generalized fine-tuning launcher for multiple models using Hugging Face Trainer API.
    """

    def __init__(self, config: ConfigLoader, profile: str):
        self.config = config
        self.profile = profile  # 'qwen2_8b' or 'llama3_7b'

        profileConfig = config.get(f'modelProfiles.{profile}')
        self.modelPath = profileConfig['modelPath']
        self.tokenizerId = profileConfig['tokenizer']

        self.dataPath = config.get('dataPaths.finetuneRoot')

        print(f"Loading model profile: {profile}")
        print("Loading tokenizer and model...")

        self.tokenizer = AutoTokenizer.from_pretrained(self.tokenizerId, trust_remote_code=True)
        self.model = AutoModelForCausalLM.from_pretrained(self.modelPath, trust_remote_code=True)

        print("Model loaded successfully.")

    def runTraining(self):
        dataset = load_dataset('json', data_files=os.path.join(self.dataPath, 'p5Subset/finetuneData.jsonl'))

        def tokenize_fn(example):
            if self.profile == "qwen2_8b":
                return self.tokenizer.apply_chat_template(example["messages"], tokenize=True, add_generation_prompt=False)
            else:
                merged = ""
                for msg in example["messages"]:
                    if msg["role"] == "user":
                        merged += f"User: {msg['content']}\n"
                    elif msg["role"] == "assistant":
                        merged += f"Assistant: {msg['content']}\n"
                return self.tokenizer(merged)

        tokenizedDataset = dataset.map(tokenize_fn, remove_columns=dataset['train'].column_names)

        args = TrainingArguments(
            output_dir=f"./finetune-{self.profile}-output",
            num_train_epochs=3,
            per_device_train_batch_size=1,
            gradient_accumulation_steps=16,
            learning_rate=2e-5,
            weight_decay=0.01,
            save_strategy="steps",
            save_steps=100,
            logging_steps=10,
            evaluation_strategy="no",
            warmup_steps=50,
            fp16=True,
            bf16=False,
            gradient_checkpointing=True,
            lr_scheduler_type="cosine",
            report_to="none"
        )

        dataCollator = DataCollatorForLanguageModeling(self.tokenizer, mlm=False)

        trainer = Trainer(
            model=self.model,
            train_dataset=tokenizedDataset['train'],
            args=args,
            data_collator=dataCollator
        )

        trainer.train()